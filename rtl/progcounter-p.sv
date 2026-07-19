module prog_counter(
    input clk, rst, b_ena,
    input stall,
    input [31:0] target,
    output reg [31:0] addr
);

    always @(posedge clk) begin
        if (stall) begin
            addr <= addr;
        end
        else begin
            if(rst) begin
                addr <= 0;
            end
            else if (b_ena) begin
                addr <= target;
            end
            else begin
                addr <= addr + 4;
            end
        end
    end
endmodule
