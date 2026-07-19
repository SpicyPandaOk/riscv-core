module add(
    input [31:0] a, b,
    output [31:0] sum);

    wire[7:0] c_outs;
    genvar i;
    generate
        for(i = 0; i < 8; i = i + 1) begin : cla_block
            if(i == 0) begin
                cla cla_piece (.a(a[3:0]), .b(b[3:0]), .cin(1'b0), .cout(c_outs[0]), .sum(sum[3:0]));
            end
            else begin
                cla cla_piece(.a(a[4*i +:4]), .b(b[4 * i+:4]), .cin(c_outs[i-1]), .cout(c_outs[i]), .sum(sum[4*i +:4]));
            end
        end
    endgenerate
endmodule

module sub(
    input [31:0] a,b,
    output [31:0] difference);

    wire[7:0] c_outs;
    genvar i;
    generate
        for(i = 0; i < 8; i = i + 1) begin : cla_block
            if(i == 0) begin
                cla cla_piece (.a(a[3:0]), .b(~b[3:0]), .cin(1'b1), .cout(c_outs[0]), .sum(difference[3:0]));
            end
            else begin
                cla cla_piece (.a(a[i*4+:4]), .b(~b[i*4+:4]), .cin(c_outs[i -1]), .cout(c_outs[i]), .sum(difference[i*4+:4]));
            end
        end
    endgenerate
endmodule


module xor_gate(
    input [31:0] a, b,
    output [31:0] result
);
    assign result = a ^ b;
endmodule

module or_gate(
    input [31:0] a, b,
    output [31:0] result
);
    assign result = a | b;
endmodule

module and_gate(
    input [31:0] a, b,
    output [31:0] result
);
    assign result = a & b;
endmodule

module sll(
    input [31:0] data,
    input [4:0] shamt,
    output [31:0] result
);
    assign result = data << shamt;
endmodule

module srl(
    input [31:0] data,
    input [4:0] shamt,
    output [31:0] result
);
    assign result = data >> shamt;
endmodule

module sra(
    input signed [31:0] data,
    input [4:0]  shamt,
    output signed [31:0] result
);
    assign result = (data) >>> shamt;
endmodule

module slt(
    input [31:0] a, b,
    output [31:0] result
);
    assign result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
endmodule

module sltu(
    input [31:0] a, b,
    output [31:0] result

);
    assign result = (a < b) ? 32'd1: 32'd0;
endmodule

        











module cla (
    input [3:0] a, b,
    input cin,
    output cout,
    output [3:0] sum);

    wire [3:0] g,p,c;
    
    assign g = a & b;
    assign p = a ^ b;


    assign c[0] = cin;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (g[0] & p[1]) | (p[1] & p[0] & c[0]);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]);

    assign cout = g[3] | (p[3] & c[3]);
    assign sum =  p  ^ c;
endmodule
