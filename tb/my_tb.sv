`include "cpu-p.sv"
module tb_cpu ();

reg clk;
reg rst;
reg [31:0]pass_count = 0;
reg [31:0]fail_count = 0;
cpu my_cpu (.clk(clk), .rst(rst));



task check_registers;
    input [4:0] reg_addr;
    input [31:0] comp_value;
    input string task_name;
    input [31:0] test_num;
    inout [31:0] pass_count;
    inout [31:0] fail_count;
    if(my_cpu.my_regs.registers[reg_addr]== comp_value) begin
        $display("[PASS] test %0d: %-30s                        x%0h = %0d", test_num, task_name, reg_addr, comp_value);
        pass_count = pass_count + 1;
    end
    else begin
        $display("[FAIL] test %0d: %-30s                        x%0h = %0d, expected %0d", test_num, task_name, reg_addr, my_cpu.my_regs.registers[reg_addr], comp_value);
        fail_count = fail_count + 1;
    end
    repeat (1) @(posedge clk);
endtask

task check_mem;
    input [31:0] mem_addr;
    input [31:0] comp_value;
    input string task_name;
    input [31:0] test_num;
    inout [31:0] pass_count;
    inout [31:0] fail_count;
    if(my_cpu.my_dmem.data[mem_addr]== comp_value) begin
        $display("[PASS] test %0d: %-30s                        mem slot %0d = %0d", test_num, task_name, mem_addr, comp_value);
        pass_count = pass_count + 1;
    end
    else begin
        $display("[FAIL] test %0d: %-30s                        mem slot %0d = %0d, expected %0d", test_num, task_name, mem_addr, my_cpu.my_dmem.data[mem_addr], comp_value);
        fail_count = fail_count + 1;
    end
    repeat (1) @(posedge clk);
endtask


always #5 clk <= ~clk;
initial begin;
$display("Starting testbench");
    clk = 0;
    rst = 1;
    repeat (5) @(posedge clk);
    rst = 0;
    repeat(200) @(posedge clk);

    check_registers(5'd1, 32'd5, "addi x1, x0, 5", 5'd1, pass_count, fail_count);
    
    $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
    $finish;
end

endmodule
