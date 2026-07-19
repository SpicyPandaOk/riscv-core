module reg_file(
    input [31:0] data,
    input reg_write, clk, 
    input [4:0] rs1, rs2, rd,
    output [31:0] r1, r2
);
    reg [31:0] registers [0:31];

  assign r1 = (reg_write && rd == rs1 && rd != 0) ? data : registers[rs1];
  assign r2 = (reg_write && rd == rs2 && rd != 0) ? data : registers[rs2];

    always @(posedge clk) begin
        if(reg_write &&( rd != 0)) begin
            registers[rd] <=  data;
        end
    end

    integer i;
    initial begin
        for(i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end
endmodule
