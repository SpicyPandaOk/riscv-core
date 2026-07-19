module forwarding_unit(
    input [4:0] ID_EX_rs1, ID_EX_rs2,
    input [4:0] EX_MEM_rd, MEM_WB_rd,
    input  EX_MEM_reg_write, MEM_WB_reg_write,
    output reg[1:0] fwd_a, fwd_b
);
    always @(*) begin
        fwd_a = 2'b00;
        fwd_b = 2'b00;
        if(EX_MEM_reg_write && EX_MEM_rd != 5'd0 && EX_MEM_rd == ID_EX_rs1) begin
            fwd_a = 2'b10;
        end
        else if(MEM_WB_reg_write && MEM_WB_rd != 5'd0 && MEM_WB_rd == ID_EX_rs1) begin
            fwd_a = 2'd01;
        end

        
        if(EX_MEM_reg_write && EX_MEM_rd != 5'd0 && EX_MEM_rd == ID_EX_rs2) begin
            fwd_b = 2'b10;
        end
        else if(MEM_WB_reg_write && MEM_WB_rd != 5'd0 && MEM_WB_rd == ID_EX_rs2) begin
            fwd_b = 2'd01;
        end
        

    end

endmodule
