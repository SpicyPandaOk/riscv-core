module hazard_unit (
    input ID_EX_data_read,
    input [4:0] ID_EX_rd,
    input [4:0] IF_ID_rs1, IF_ID_rs2,
    output reg stall
);
  always @(*) begin
    stall = ID_EX_data_read && (ID_EX_rd == IF_ID_rs1 || IF_ID_rs2 == ID_EX_rd);
  end  
endmodule

