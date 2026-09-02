module alu_control (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    input [31:0] imm,
    output reg [4:0] sel,
    output reg high,
    output reg r1_unsigned,
    output reg r2_unsigned
);

    localparam ALU_add = 5'd0, ALU_sub = 5'd1, ALU_xor = 5'd2, ALU_or = 5'd3, ALU_and = 5'd4, ALU_sll = 5'd5, ALU_srl = 5'd6, ALU_sra = 5'd7, ALU_slt = 5'd8, ALU_sltu = 5'd9, ALU_mul = 5'd10;
    localparam ALU_div = 5'd11, ALU_rem = 5'd12;

    always @(*) begin
        high = 0;
        r1_unsigned =1'b0;
        r2_unsigned = 1'b0;

        case (opcode)
            7'b0110011: begin
                case (funct3)
                    3'h0: begin
                        case(funct7)
                            7'h01: sel = ALU_mul;
                            7'h00: sel = ALU_add;
                            7'h20: sel = ALU_sub;
                        endcase
                        
                    end
                    3'h1: begin
                        case(funct7)
                            7'h01:begin
                                sel = ALU_mul;
                                high = 1'b1;
                            end
                            7'h00: sel = ALU_sll;
                        endcase 
                    end
                    3'h2: begin
                        case(funct7)
                            7'h01: begin
                                sel = ALU_mul;
                                r2_unsigned = 1'b1;
                                high = 1'b1;
                            end
                            7'h00: sel = ALU_slt;
                        endcase
                    end
                    3'h3: begin
                        case(funct7)
                            7'h01: begin
                                sel = ALU_mul;
                                r2_unsigned = 1'b1;
                                r1_unsigned = 1'b1;
                                high = 1'b1;
                            end
                            7'h00: sel = ALU_sltu;
                        endcase
                    end
                    3'h4:begin
                        case(funct7)
                            7'h01: begin
                                sel = ALU_div;
                            end
                            7'h00: sel = ALU_xor;
                        endcase
                    end
                    3'h5: begin
                        case(funct7)
                            7'h01: begin
                                sel = ALU_div;
                                r1_unsigned = 1'b1;
                                r2_unsigned = 1'b1;
                            end
                            7'h00: sel = ALU_srl;
                            7'h20: sel = ALU_sra;
                        endcase
                    end
                    3'h6: begin
                        case(funct7)
                            7'h01: begin
                                sel = ALU_rem;

                            end
                            7'h00: sel = ALU_or;
                        endcase
                    end
                    3'h7: begin
                        case(funct7)
                            7'h01: begin
                                sel = ALU_rem;
                                r1_unsigned = 1'b1;
                                r2_unsigned = 1'b1;
                            end
                            7'h00: sel = ALU_and;
                        endcase
                    end
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
