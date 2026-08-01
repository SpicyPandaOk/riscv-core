`include "cpu-p.sv"
module tb_cpu ();

reg clk;
reg rst;
reg [31:0]pass_count = 0;
reg [31:0]fail_count = 0;


reg [256*8-1:0] line_buffer;
string test_names [0:255];
integer line_idx = 0;
integer task_count = 0;
cpu my_cpu (.clk(clk), .rst(rst));
integer file_handle;
string line_str;

task check_registers;
    input [4:0] reg_addr;
    input [31:0] comp_value;


    if(my_cpu.my_regs.registers[reg_addr]== comp_value) begin
        $display("[PASS] test %0d: %-30s                        x%0h = %0d", task_count, test_names[task_count], reg_addr, comp_value);
        pass_count = pass_count + 1;
    end
    else begin
        $display("[FAIL] test %0d: %-30s                        x%0h = %0d, expected %0d", task_count, test_names[task_count], reg_addr, my_cpu.my_regs.registers[reg_addr], comp_value);
        fail_count = fail_count + 1;
    end
    repeat (1) @(posedge clk);
    task_count += 1;

endtask

task check_mem;
    input [31:0] mem_addr;
    input [31:0] comp_value;
    input [31:0] test_num;


    if(my_cpu.my_dmem.data[mem_addr]== comp_value) begin
        $display("[PASS] test %0d: %s                        mem slot %0d = %0d", task_count, test_names[task_count], mem_addr, comp_value);
        pass_count = pass_count + 1;
    end
    else begin
        $display("[FAIL] test %0d: %-30s                        mem slot %0d = %0d, expected %0d", task_count, test_names[task_count], mem_addr, my_cpu.my_dmem.data[mem_addr], comp_value);
        fail_count = fail_count + 1;
    end
    repeat (1) @(posedge clk);
    task_count += 1;

endtask


always #5 clk <= ~clk;

initial begin
    file_handle = $fopen("../sw/assembly.txt", "r");
    if (file_handle == 0) begin
        $display("Error: Could not open assembly.txt");
        $finish;
    end


    while (!$feof(file_handle) && line_idx < 256) begin
        line_buffer = 0;
        if ($fgets(line_buffer, file_handle)) begin
            line_str = string'(line_buffer);
            while (line_str.len() > 0 && line_str[line_str.len()-1] < 8'h20) begin
                line_str = line_str.substr(0, line_str.len()-2);
            end
            if (line_str.len() > 0 && line_str[0] != "#" && !(line_str.substr(line_str.len()-1, line_str.len()-1) == ":")) begin
                test_names[line_idx] = line_str;
                line_idx = line_idx + 1;
            end
        end
    end
    $fclose(file_handle);

    $display("Total lines read: %0d", line_idx);
    for (int k = 0; k < line_idx; k++) begin
          $display("Line %0d: [%s]", k, test_names[k]);

    end

end




initial begin;
    $display("Starting testbench");
    clk = 0;
    rst = 1;
    repeat (5) @(posedge clk);
    rst = 0;
    repeat(5) @(posedge clk);

    check_registers(5'd1, 32'd2);
    check_registers(5'd1, 32'd0);

    $display("Passed: %0d, Failed: %0d", pass_count, fail_count);
    $finish;
end



endmodule
