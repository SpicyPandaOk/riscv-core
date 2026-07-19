module alu_control (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    input [31:0] imm,
    output reg [4:0] sel
);

    localparam ALU_add = 5'd0, ALU_sub = 5'd1, ALU_xor = 5'd2, ALU_or = 5'd3, ALU_and = 5'd4, ALU_sll = 5'd5, ALU_srl = 5'd6, ALU_sra = 5'd7, ALU_slt = 5'd8, ALU_sltu = 5'd9;
    


    always @(*) begin
        case (opcode)
            7'b0110011: begin
                case (funct3)
                    3'h0: sel = (funct7 == 7'h00) ? ALU_add : ALU_sub;
                    3'h4: sel = ALU_xor;
                    3'h6: sel = ALU_or;
                    3'h7: sel = ALU_and;
                    3'h1: sel = ALU_sll;
                    3'h5: sel = (funct7 == 7'h00) ? ALU_srl : ALU_sra;
                    3'h2: sel = ALU_slt;
                    3'h3: sel = ALU_sltu;
                    default: sel = ALU_add;
                endcase

            end 


            7'b0010011: begin
                case (funct3)
                    3'h0 : sel = ALU_add;
                    3'h4 : sel = ALU_xor;
                    3'h6: sel = ALU_or;
                    3'h7: sel = ALU_and;
                    3'h1: sel = ALU_sll;
                    3'h5: sel = (imm[11:5] == 7'h00) ? ALU_srl : ALU_sra;
                    3'h2: sel = ALU_slt;
                    3'h3: sel = ALU_sltu;
                    default: sel = ALU_add;
                endcase
                
            end

            7'b0000011: sel = ALU_add;

            7'b0100011: sel = ALU_add;

            7'b1100011: sel = ALU_sub;

            7'b1101111: sel = ALU_add;

            7'b1100111: sel = ALU_add;

            7'b0110111: sel = ALU_add;

            7'b0010111: sel = ALU_add;

            default: sel = ALU_add; 
        endcase
    end

endmodule
