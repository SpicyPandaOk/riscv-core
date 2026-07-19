module control(
    input [6:0] opcode,
    output reg reg_write, data_write, data_read, mem_to_reg, ALU_src, branch, jump, jalr

);


    always @(*) begin
        reg_write = 0; 
        data_write = 0;
        data_read = 0;
        mem_to_reg = 0;
        ALU_src = 0;
        branch = 0;
        jump = 0;
        jalr = 0;
        case (opcode)
            7'b0110011: begin
                reg_write = 1;
            end

            7'b0010011: begin
                reg_write = 1;
                ALU_src = 1;
            end

            7'b0000011: begin
                reg_write = 1;
                data_read = 1;
                mem_to_reg = 1;
                ALU_src = 1;
            end

            7'b0100011: begin
                data_write = 1;
                ALU_src = 1;
            end 

            7'b1100011: begin
                branch =1;
            end

            7'b1101111: begin
                reg_write = 1;
                jump = 1;
            end
            7'b1100111: begin
                reg_write = 1;
                jump = 1;
                jalr = 1;
                ALU_src = 1;
            end 

            7'b0110111, 7'b0010111: begin
                reg_write = 1;
                ALU_src = 1;
            end
        endcase
    end
endmodule
