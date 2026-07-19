module instdecoder (
    input [31:0] instr,
    output reg[6:0] funct7,
    output reg[4:0] rs1, rs2,
    output reg[4:0] rd,
    output reg[2:0] funct3,
    output reg [6:0] opcode,
    output reg [31:0] imm,
    output reg [2:0] inst_type
);

    localparam R_type = 3'd0, I_type = 3'd1, S_type = 3'd2, B_type = 3'd3, U_type = 3'd4, J_type = 3'd5;
    always@(*) begin
        funct7 = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        funct3 = 0;
        opcode = 0;
        imm = 0;
        inst_type = 0;
        
        case(instr[6:0])
            //R type
            7'b0110011: begin
                funct7 = instr[31:25];
                rs2 = instr[24:20];
                rs1 = instr[19:15];
                funct3 = instr[14:12];
                rd = instr[11:7];
                opcode = instr[6:0];
                inst_type = R_type;
            end
            //I type
            7'b0010011, 7'b0000011, 7'b1100111: begin
                imm[31:0] = {{20{instr[31]}}, instr[31:20]};
                rs1 = instr[19:15];
                funct3 = instr[14:12];
                rd = instr[11:7];
                opcode = instr[6:0];
                inst_type = I_type;
            end
            // S type
            7'b0100011: begin
                imm[11:5] = instr[31:25];
                rs2 = instr[24:20];
                rs1 = instr[19:15];
                funct3 = instr[14:12];
                imm[4:0] = instr[11:7];
                opcode = instr[6:0];
                inst_type = S_type;
                imm[31:12] = {20{instr[31]}};
            end
            // B type
            7'b1100011: begin
                imm[12] = instr[31];
                imm[10:5] = instr[30:25];
                rs2 = instr[24:20];
                rs1 = instr[19:15];
                funct3 = instr[14:12];
                imm[4:1] = instr[11:8];
                imm[11] = instr[7];
                opcode = instr[6:0];
                inst_type = B_type;
                imm[31:12] = {20{instr[31]}};
            end
            // U type
            7'b0110111, 7'b0010111: begin
                imm[31:12] = instr[31:12];
                rd = instr[11:7];
                opcode = instr[6:0];
                inst_type = U_type;
            end
            // J type
            7'b1101111: begin
                imm[20] = instr[31];
                imm[10:1] = instr[30:21];
                imm[11] = instr[20];
                imm[19:12] = instr[19:12];
                rd = instr[11:7];
                opcode = instr[6:0];
                inst_type = J_type;
                imm[31:21] = {11{instr[31]}};
            end


        endcase
    end

endmodule
