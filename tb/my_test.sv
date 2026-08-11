`include "cpu-p.sv"

module tb_cpu ();

reg clk;
reg rst;

reg [31:0] result;


cpu my_cpu(.clk(clk), .rst(rst));

always #5 clk <= ~clk;


task startup;
    rst = 1;
    clk = 0;

    repeat (5) @(posedge clk);
    rst = 0;


endtask

task run_prog;
    input [31:0] cycles;
    repeat (cycles) @(posedge clk);
endtask


integer i;

initial begin
    startup();
    run_prog(200);

    $display("-----FINAL REGS-----");
    for(i = 0; i < 32; i = i + 1) begin
        $display("x%0d = %0d", i, my_cpu.my_regs.registers[i]);
    end

    $display("-----FINAL DATA MEM-----");
    for(i = 0; i < 16; i = i + 1) begin
        $display("mem[%0d] = %0d", i, my_cpu.my_dmem.data[i]);
    end
    $finish;
end
endmodule