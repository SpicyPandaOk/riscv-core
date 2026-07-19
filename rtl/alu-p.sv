module alu(
    input [4:0] sel,
    input [31:0] r1, r2,
    output reg [31:0] result,
    output reg overflow, negative, zero
);

    wire [31:0] add_out, sub_out, xor_out, or_out, and_out, sll_out, srl_out, sra_out, slt_out, sltu_out;
    add adder(.a(r1), .b(r2), .sum(add_out));
    sub subber(.a(r1), .b(r2), .difference(sub_out));
    xor_gate xorer(.a(r1), .b(r2), .result(xor_out));
    or_gate orer (.a(r1), .b(r2), .result(or_out));
    and_gate ander (.a(r1), .b(r2), .result(and_out));
    sll sller (.data(r1), .shamt(r2[4:0]), .result(sll_out));
    srl srler(.data(r1), .shamt(r2[4:0]), .result(srl_out));
    sra sraer(.data(r1), .shamt(r2[4:0]), .result(sra_out));
    slt slter(.a(r1), .b(r2), .result(slt_out));
    sltu sltuer(.a(r1), .b(r2), .result(sltu_out));

    always @(*) begin
        case(sel)
            5'd0: result = add_out;
            5'd1: result = sub_out;
            5'd2: result = xor_out;
            5'd3: result = or_out;
            5'd4: result = and_out;
            5'd5: result = sll_out;
            5'd6: result = srl_out;
            5'd7: result = sra_out;
            5'd8: result = slt_out;
            5'd9: result = sltu_out;
            default: result = add_out;
        endcase

       
        case(sel)
            5'd0: overflow = (r1[31] == r2[31] && r1[31] != result[31])? 1'd1: 1'd0;
            5'd1: overflow = (r1[31] != r2[31] && r1[31] != result[31]) ? 1'd1: 1'd0;
            default: overflow = 1'd0;
        endcase
       
        negative = (result[31] == 1'd1) ? 1'd1: 1'd0;
        zero = result == 32'b0;
            
    end


endmodule
