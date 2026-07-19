`include "instdecoder-p.sv"
`include "ops-p.sv"
`include "forwardunit-p.sv"
`include "alu-p.sv"
`include "alucontrol-p.sv"
`include "control-p.sv"
`include "datamem-p.sv"
`include "hazarddetect-p.sv"
`include "registers-p.sv"
`include "instmem-p.sv"
`include "progcounter-p.sv"

module cpu (
    input clk, rst
);

    reg [31:0] IF_ID_pc;
    reg [31:0] IF_ID_instr;

    reg [31:0] ID_EX_pc;
    reg [31:0] ID_EX_r1, ID_EX_r2;
    reg [4:0] ID_EX_rs1, ID_EX_rs2, ID_EX_rd;
    reg[31:0] ID_EX_imm;
    reg[2:0] ID_EX_funct3;
    reg [6:0] ID_EX_funct7, ID_EX_opcode;
    reg ID_EX_reg_write, ID_EX_mem_to_reg, ID_EX_data_read, ID_EX_data_write, ID_EX_branch, ID_EX_jump, ID_EX_jalr, ID_EX_ALU_src;
    reg [4:0] ID_EX_ALU_sel;



    reg [31:0] EX_MEM_ALU_result, EX_MEM_r2, EX_MEM_addr, EX_MEM_pc;
    reg [4:0] EX_MEM_rd;
    reg [2:0] EX_MEM_funct3;
    reg EX_MEM_reg_write, EX_MEM_mem_to_reg, EX_MEM_data_read, EX_MEM_data_write, EX_MEM_branch, EX_MEM_jump, EX_MEM_jalr, EX_MEM_branch_taken, EX_MEM_zero, EX_MEM_overflow, EX_MEM_negative;
    reg [31:0] EX_MEM_branch_target;

    reg [31:0] MEM_WB_ALU_result, MEM_WB_read_data, MEM_WB_pc;
    reg [4:0] MEM_WB_rd;
    reg MEM_WB_reg_write, MEM_WB_mem_to_reg, MEM_WB_jump;

    localparam R_type = 3'd0, I_type = 3'd1, S_type = 3'd2, B_type = 3'd3, U_type = 3'd4, J_type = 3'd5;


    wire [31:0] pc, instr, r1, r2, imm, result, read_data;
    wire [4:0] rs1, rs2, rd, sel;
    wire [2:0] funct3, inst_type;
    wire [6:0] funct7, opcode;
    wire reg_write, mem_to_reg, data_read, data_write, branch, jump, jalr, ALU_src, zero, overflow, negative;
    wire flush;


    reg [1:0] fwd_a, fwd_b;
    reg [31:0] alu_a, alu_a_reg, alu_b, alu_b_reg, branch_target;
    reg[31:0] wb_data;
    wire stall;
    reg branch_taken;

    always @(*) begin
        branch_taken = 1'b0;
        if(ID_EX_branch) begin
            case (ID_EX_funct3)
                3'h0: branch_taken = alu_a_reg == alu_b_reg;
                3'h1: branch_taken = alu_a_reg != alu_b_reg;
                3'h4: branch_taken = ($signed(alu_a_reg) < $signed(alu_b_reg));
                3'h5: branch_taken = ($signed(alu_a_reg) >= $signed(alu_b_reg));
                3'h6: branch_taken = alu_a_reg < alu_b_reg;
                3'h7: branch_taken = alu_a_reg >= alu_b_reg;
                default: branch_taken = 1'b0;
            endcase
        end
        

    end
    always@(*) begin
        case ({MEM_WB_jump, MEM_WB_mem_to_reg})
            2'b00: wb_data  = MEM_WB_ALU_result;
            2'b01: wb_data  = MEM_WB_read_data;
            2'b10: wb_data  = MEM_WB_pc + 32'd4; 
            default: wb_data = MEM_WB_ALU_result;
        endcase
    end

    always @(*) begin
        case({branch_taken, ID_EX_jump, ID_EX_jalr})
            3'b100, 3'b010: branch_target = (ID_EX_imm) + ID_EX_pc;
            3'b011: branch_target = result;
            3'b001: branch_target = alu_a_reg + ID_EX_imm;
            default: branch_target = pc + 32'd4;
        endcase
    end
    
    always @(*) begin
        case (fwd_a)
            2'b00: alu_a_reg = ID_EX_r1;
            2'b01: alu_a_reg = wb_data;
            2'b10: alu_a_reg = EX_MEM_ALU_result; 
            default: alu_a_reg = ID_EX_r1;
        endcase
        case (fwd_b)
            2'b00: alu_b_reg = ID_EX_r2;
            2'b01: alu_b_reg = wb_data;
            2'b10: alu_b_reg = EX_MEM_ALU_result; 
            default: alu_b_reg = ID_EX_r2;
        endcase

        alu_b = ID_EX_ALU_src ? ID_EX_imm : alu_b_reg;
        alu_a = ID_EX_opcode == 7'b0010111 ? ID_EX_pc  : alu_a_reg;
    end

    
    assign flush = EX_MEM_branch_taken || EX_MEM_jump || EX_MEM_jalr;


    prog_counter my_pc (
        .clk(clk),
        .rst(rst),
      .b_ena(EX_MEM_branch_taken || EX_MEM_jump || EX_MEM_jalr),
        .addr(pc),
        .target(EX_MEM_branch_target),
        .stall(stall)
    );

    instmem my_imem (
        .addr(pc),
        .instr(instr)
    );

    instdecoder my_idec (
        .instr(IF_ID_instr),
        .funct7(funct7),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .funct3(funct3),
        .opcode(opcode),
        .imm(imm),
        .inst_type(inst_type)
    );

    reg_file my_regs (
        .data(wb_data),
        .reg_write(MEM_WB_reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(MEM_WB_rd),
        .r1(r1),
      .r2(r2),
      .clk(clk)
    );

    control my_control(
        .opcode(opcode),
        .reg_write(reg_write),
        .data_write(data_write),
        .data_read(data_read),
        .mem_to_reg(mem_to_reg),
        .ALU_src(ALU_src),
        .branch(branch),
        .jump(jump),
        .jalr(jalr)
    );

    alu_control my_alu_control (
        .opcode(ID_EX_opcode),
        .funct3(ID_EX_funct3),
        .funct7(ID_EX_funct7),
        .imm(ID_EX_imm),
        .sel(sel)
    );

    alu my_alu (
        .sel(sel),
        .r1(alu_a),
        .r2(alu_b),
        .result(result),
        .overflow(overflow),
        .negative(negative),
        .zero(zero)
    );

    data_mem my_dmem (
        .clk(clk),
        .mem_write(EX_MEM_data_write),
        .mem_read(EX_MEM_data_read),
        .funct3(EX_MEM_funct3),
        .addr(EX_MEM_addr),
        .write_data(EX_MEM_r2),
        .read_data(read_data)
    );


    forwarding_unit my_fwd(
        .ID_EX_rs1(ID_EX_rs1),
        .ID_EX_rs2(ID_EX_rs2),
        .EX_MEM_rd(EX_MEM_rd),
        .MEM_WB_rd(MEM_WB_rd),
        .EX_MEM_reg_write(EX_MEM_reg_write),
        .MEM_WB_reg_write(MEM_WB_reg_write),
        .fwd_a(fwd_a),
        .fwd_b(fwd_b)
    );

    hazard_unit my_hazard(
        .ID_EX_data_read(ID_EX_data_read),
        .ID_EX_rd(ID_EX_rd),
        .IF_ID_rs1(IF_ID_instr[19:15]),
        .IF_ID_rs2(IF_ID_instr[24:20]),
        .stall(stall)
    );




    always@(posedge clk) begin
        if(rst) begin
            IF_ID_pc <= 32'b0;
            IF_ID_instr <= 32'b0;
            ID_EX_reg_write <= 1'b0;
            ID_EX_data_write <= 1'b0;
            ID_EX_mem_to_reg <= 1'b0;
            ID_EX_data_read <= 1'b0;
            ID_EX_branch <= 1'b0;
            ID_EX_jump <= 1'b0;
            ID_EX_jalr <= 1'b0;
            ID_EX_ALU_src <= 1'b0;
            ID_EX_ALU_sel <= 5'b0;

             EX_MEM_ALU_result    <= 1'b0;
            EX_MEM_r2            <= 1'b0;
            EX_MEM_addr          <= 1'b0;
            EX_MEM_funct3        <= 1'b0;
            EX_MEM_rd            <= 1'b0;
            EX_MEM_mem_to_reg    <= 1'b0;
            EX_MEM_branch        <= 1'b0;
            EX_MEM_jump          <= 1'b0;
            EX_MEM_jalr          <= 1'b0;
            EX_MEM_branch_taken  <= 1'b0;
            EX_MEM_zero          <= 1'b0;
            EX_MEM_overflow      <= 1'b0;
            EX_MEM_negative      <= 1'b0;
            EX_MEM_branch_target <= 1'b0;
            EX_MEM_pc            <= 1'b0;

            MEM_WB_reg_write <= 1'b0;
            MEM_WB_mem_to_reg <= 1'b0;
            MEM_WB_jump <= 1'b0;
        end
        else begin
          
          
          	EX_MEM_ALU_result    <= result;
            EX_MEM_r2            <= alu_b_reg;
            EX_MEM_addr          <= result;
            EX_MEM_funct3        <= ID_EX_funct3;
            EX_MEM_rd            <= ID_EX_rd;
            EX_MEM_mem_to_reg    <= ID_EX_mem_to_reg;
            EX_MEM_branch        <= ID_EX_branch;
            EX_MEM_jump          <= ID_EX_jump;
            EX_MEM_jalr          <= ID_EX_jalr;
            EX_MEM_branch_taken  <= branch_taken;
            EX_MEM_zero          <= zero;
            EX_MEM_overflow      <= overflow;
            EX_MEM_negative      <= negative;
            EX_MEM_branch_target <= branch_target;
            EX_MEM_pc            <= ID_EX_pc;
			
              
              
            MEM_WB_ALU_result    <= EX_MEM_ALU_result;
            MEM_WB_read_data     <= read_data;
            MEM_WB_rd            <= EX_MEM_rd;
            MEM_WB_reg_write     <= EX_MEM_reg_write;
            MEM_WB_mem_to_reg    <= EX_MEM_mem_to_reg;
            MEM_WB_pc            <= EX_MEM_pc;
            MEM_WB_jump          <= EX_MEM_jump;
          
          
          
            if(flush) begin
              
                IF_ID_instr <= 32'b0;
              
                ID_EX_reg_write <= 1'b0;
                ID_EX_data_write <= 1'b0;
                ID_EX_mem_to_reg <= 1'b0;
                ID_EX_data_read <= 1'b0;
                ID_EX_branch <= 1'b0;
                ID_EX_jump <= 1'b0;
                ID_EX_jalr <= 1'b0;
                ID_EX_ALU_src <= 1'b0;
                ID_EX_ALU_sel <= 5'b0;
              	ID_EX_pc <= 32'b0;
                ID_EX_r1 <= 32'b0;
                ID_EX_r2 <= 32'b0;
                ID_EX_rs1 <= 5'b0;
                ID_EX_rs2 <= 5'b0;
                ID_EX_rd <= 5'b0;
                ID_EX_imm <= 32'b0;
                ID_EX_funct3 <= 3'b0;
                ID_EX_funct7 <= 7'b0;
                ID_EX_opcode <= 7'b0;
              
              	EX_MEM_reg_write <= 1'b0;
                EX_MEM_data_write <= 1'b0;
                EX_MEM_data_read <= 1'b0;
                EX_MEM_jump <= 1'b0;
                EX_MEM_jalr <= 1'b0;
                EX_MEM_branch_taken <= 1'b0;
            end

            else if(stall) begin
                IF_ID_pc         <= IF_ID_pc;
                IF_ID_instr      <= IF_ID_instr;

                ID_EX_reg_write  <= 1'b0;
                ID_EX_data_write <= 1'b0;
                ID_EX_data_read  <= 1'b0;
                ID_EX_branch     <= 1'b0;
                ID_EX_jump       <= 1'b0;
                ID_EX_jalr       <= 1'b0;
                
                EX_MEM_reg_write <= ID_EX_reg_write;
                EX_MEM_data_read <= ID_EX_data_read;
                EX_MEM_data_write <= ID_EX_data_write;
           end
           else begin
            	IF_ID_pc         <= pc;
                IF_ID_instr      <= instr;

                // ID_EX Stage Update
                ID_EX_pc         <= IF_ID_pc;
                ID_EX_r1         <= r1;
                ID_EX_r2         <= r2;
                ID_EX_rs1        <= rs1;
                ID_EX_rs2        <= rs2;
                ID_EX_rd         <= rd;
                ID_EX_imm        <= imm;
                ID_EX_funct3     <= funct3;
                ID_EX_funct7     <= funct7;
                ID_EX_opcode     <= opcode;
                ID_EX_reg_write  <= reg_write;
                ID_EX_mem_to_reg <= mem_to_reg;
                ID_EX_data_read  <= data_read;
                ID_EX_data_write <= data_write;
                ID_EX_branch     <= branch;
                ID_EX_jump       <= jump;
                ID_EX_jalr       <= jalr;
                ID_EX_ALU_src    <= ALU_src;
                ID_EX_ALU_sel    <= sel;


                //EX_MEM control signals
                EX_MEM_reg_write    <= ID_EX_reg_write;
                EX_MEM_data_read    <= ID_EX_data_read;
                EX_MEM_data_write   <= ID_EX_data_write;

              
           end
         	
          
        end
        
        

    end
endmodule


