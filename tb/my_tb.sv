`include "cpu-p.sv"
module tb_cpu ();

reg clk;
reg rst;
reg [31:0]pass_count = 0;
reg [31:0]fail_count = 0;

reg [256*8-1:0] line_buffer;
string test_names [0:255];
integer pc_counts [0:255];
integer line_idx = 0;
integer task_count = 0;

integer file_handle;
string line_str;

integer EX_MEM_pc;
integer MEM_WB_pc;


integer retire_count = 0;
integer last_MEM_WB_pc = -1;


localparam reg_task = 1'b0, mem_task = 1'b1;


cpu my_cpu (.clk(clk), .rst(rst));

assign EX_MEM_pc = my_cpu.EX_MEM_pc;
assign MEM_WB_pc = my_cpu.MEM_WB_pc;

always #5 clk <= ~clk;

// always @(posedge clk) begin
//     $display("MEM_WB_jump: %d, MEM_WB_mem_to_reg: %d", my_cpu.MEM_WB_jump, my_cpu.MEM_WB_mem_to_reg);

// end


always @(posedge clk) begin

    if (!rst && MEM_WB_pc != last_MEM_WB_pc) begin
        if (MEM_WB_pc != -1) begin
            retire_count <= retire_count + 1;
        end
        last_MEM_WB_pc <= MEM_WB_pc;
    end
end



task check_registers;
    input [4:0] reg_addr;
    input signed [31:0] comp_value;
    input  string  name;
    wait_for_retire();
    if(my_cpu.my_regs.registers[reg_addr]== comp_value) begin
        $display("[PASS] test %0d: %-30s                        x%0d = %0d", task_count, name, reg_addr, comp_value);
        pass_count = pass_count + 1;
    end
    else begin
        $display("[FAIL] test %0d: %-30s                        x%0d = %0d, expected %0d", task_count, name, reg_addr, my_cpu.my_regs.registers[reg_addr], comp_value);
        fail_count = fail_count + 1;
    end

    task_count += 1;

endtask



task wait_for_retire;
    while (retire_count  < task_count + 1)
    @ (posedge clk);
endtask



task check_mem;
    input [31:0] mem_addr;
    input signed  [31:0] comp_value;
    input string name;
    wait_for_retire();
    if(my_cpu.my_dmem.data[mem_addr]== comp_value) begin
        $display("[PASS] test %0d: %s                        mem slot %0d = %0d", task_count, name, mem_addr, comp_value);
        pass_count = pass_count + 1;
    end
    else begin
        $display("[FAIL] test %0d: %-30s                        mem slot %0d = %0d, expected %0d", task_count, name, mem_addr, my_cpu.my_dmem.data[mem_addr], comp_value);
        fail_count = fail_count + 1;
    end
    task_count += 1;

endtask

task skip_instr;
    input string name;
    wait_for_retire();
    task_count += 1;    
endtask




initial begin;
    $display("Starting testbench");
    clk = 0;
    rst = 1;
    repeat (5) @(posedge clk);
    rst = 0;
    $display("\nStarting first set of tests: immediates");
    check_registers(5'd1, 32'd2, "addi x1, x0, 2"); //addi
    check_registers(5'd2, 32'd1, "xori x2, x1, 3"); //xori
    check_registers(5'd3, 32'd1, "ori x3, x2, 1"); //ori
    check_registers(5'd4, 32'd1, "andi x4, x3, 3"); //andi
    check_registers(5'd5, 32'd4, "slli x5, x4, 2"); //slli
    check_registers(5'd6, 32'd1, "srli x6, x5, 2"); //srli
    skip_instr("addi x6, x0, -5"); //addi
    check_registers(5'd7, -32'd2 , "srai x7, x6, 2"); //srai
    check_registers(5'd8, 32'd0, "slti x8, x7, -3"); //slti
    check_registers(5'd9, 32'd1, "sltiu x9, x8, 5"); //sltiu
    $display("\nStarting second set of tests: base arithmetic");
    check_registers(5'd10, 32'd1, "add x10, x9, x8"); //add
    check_registers(5'd11, 32'd0, "sub x11, x10, x9"); //sub
    check_registers(5'd12, 32'd1, "xor x12, x11, x10"); //xor
    check_registers(5'd13, 32'd1, "or x13, x12, x11"); //or
    check_registers(5'd14, 32'd1, "and x14, x13, x12"); //and
    check_registers(5'd15, 32'd2, "sll x15, x14, x13"); //sll
    check_registers(5'd16, 32'd1, "srl x16, x15, x14"); //srl
    skip_instr("addi x16, x0, -5"); //addi
    check_registers(5'd17, -32'd2, "sra x17, x16, x15"); //sra
    check_registers(5'd18, 32'd0, "slt x18, x17, x16"); //slt
    check_registers(5'd19, 32'd1, "sltu x19, x18, x17"); //sltu
    $display("\nStarting third set of tests: memory");
    check_mem(32'd0, 32'd2, "sw x1, 0(x0)"); //sw
    check_mem(32'd1, 32'd4, "sb x5, 4(x0)"); //sb
    check_mem(32'd2, 32'd1, "sh x9, 8(x0)"); //sh  
    check_registers(5'd20, 32'd2, "lb x20, 0(x0)"); //lb
    check_registers(5'd21, 32'd4, "lh x21, 4(x0)"); //lh
    check_registers(5'd22, 32'd1, "lw x22, 8(x0)"); //lw
    $display("\nStarting fourth set of tests: branches");
    skip_instr("beq x0, x0, 8"); //beq
    check_registers(5'd2, 32'd50, "addi x2, x0, 50 (branch taken)"); //addi
    skip_instr("bne x0, x2, 8"); //bne
    check_registers(5'd3, 32'd40, "addi x3, x0, 40 (branch taken)"); //addi
    skip_instr("blt x3, x2, 8"); //blt
    check_registers(5'd4, 32'd30, "addi x4, x0, 30 (branch taken)"); //addi
    skip_instr("bge x2, x3, 8"); //bge
    check_registers(5'd5, 32'd20, "addi x5, x0, 20 (branch taken)"); //addi
    skip_instr("bltu x3, x2, 8"); //bltu
    check_registers(5'd6, 32'd10, "addi x6, x0, 10 (branch taken)"); //addi 
    skip_instr("bgeu x2, x3, 8"); //bgeu
    check_registers(5'd7, 32'd5, "addi x7, x0, 5 (branch taken)"); //addi
    skip_instr("bne x0, x0, 12 (should not branch)"); //bne
    check_registers(5'd8, 32'd60, "addi x8, x0, 60 (branch not taken)"); //addi
    $display("\nStarting fifth set of tests: various");
    skip_instr("jal x1, test5_various)"); //jal
    check_registers(5'd5, 32'd2, "lw x5 0(x0)"); //lw
    check_registers(5'd6, 32'd4, "add x6, x5, x5 load use hazard"); //add
    check_registers(5'd0, 32'd0, "addi x0, x0, 5 (x0 should always be 0)"); //x0
    check_registers(5'd1, 32'd212, "jal x1, 12 (test link)"); //jal
    check_registers(5'd15, 32'd819200, "lui x15, 0xC8 (test lui)"); //lui
    $display("\nPassed: %0d, Failed: %0d", pass_count, fail_count);
    $finish;
end
initial begin
    repeat (400) @(posedge clk);
    $finish;
end

endmodule