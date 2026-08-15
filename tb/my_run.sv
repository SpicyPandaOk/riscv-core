`include "cpu-p.sv"

module tb_cpu ();

reg clk;
reg rst;


wire [31:0] mem_wb_pc;
reg [31:0] last_mem_wb_pc;


integer same_pc_count = 0;
localparam halt_thresh = 8;

cpu my_cpu(.clk(clk), .rst(rst));

always #5 clk <= ~clk;

assign mem_wb_pc = my_cpu.MEM_WB_pc;



    
always @(posedge clk) begin
    if(!rst) begin
        if(mem_wb_pc !== 32'hffffffff) begin
            if(mem_wb_pc == last_mem_wb_pc)
            begin
                same_pc_count <= same_pc_count + 1;

            end
            else begin
                same_pc_count <= 0;
            end
            last_mem_wb_pc <= mem_wb_pc;
        end
       
    end
end

task startup;
    rst = 1;
    clk = 0;

    repeat (5) @(posedge clk);
    rst = 0;


endtask


task run_prog;
    while(same_pc_count < halt_thresh) begin
        @(posedge clk);
    end
endtask    



task stall_time;
    input integer max_cycles;
    repeat (max_cycles) @(posedge clk);
    $finish;
endtask


integer i;

initial begin
    startup();
    run_prog();

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

initial begin
    stall_time(500);
end
endmodule