`timescale 1ns/1ps
`include "cpu-p.sv"

// Runs the single combined program (instmemp.hex / combined.s) start-to-finish
// with ONE reset, exactly as it would run on real hardware, and reports
// pass/fail for every checkpoint -- including registers that get reused and
// overwritten by later sections.
//
// How this handles register reuse: instead of snapshotting the register file
// at a guessed cycle number, every check is tagged with the exact source PC
// of the instruction that's supposed to produce it. A background monitor
// watches the writeback stage every cycle and captures the value the instant
// that specific instruction retires -- so it doesn't matter that x1, x2, etc.
// get overwritten many more times later in the same run.
//
// "Must be squashed" checks work the same way in reverse: they watch for a
// writeback ever occurring from that PC/register at all, and fail if it ever
// does (a squashed wrong-path instruction must NEVER reach writeback).

module combined_tb;

    reg clk = 0;
    reg rst;

    cpu dut (.clk(clk), .rst(rst));

    always #5 clk = ~clk;



    reg [31:0] pos_pc   [0:NUM_POS-1];
    reg [4:0]  pos_rd   [0:NUM_POS-1];
    reg [31:0] pos_exp  [0:NUM_POS-1];
    reg        pos_cap  [0:NUM_POS-1];
    reg [31:0] pos_val  [0:NUM_POS-1];
    string     pos_desc [0:NUM_POS-1];

    reg [31:0] neg_pc   [0:NUM_NEG-1];
    reg [4:0]  neg_rd   [0:NUM_NEG-1];
    reg        neg_hit  [0:NUM_NEG-1];
    string     neg_desc [0:NUM_NEG-1];

    integer    mem_idx  [0:NUM_MEM-1];
    reg [31:0] mem_exp  [0:NUM_MEM-1];
    string     mem_desc [0:NUM_MEM-1];

    integer i;
    integer pass_count = 0;
    integer fail_count = 0;

    // ------------------------------------------------------------------
    // Background monitor: fires every cycle, catches every retiring
    // instruction by its unique (pc, rd) tag.
    // ------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rst) begin
            for (i = 0; i < NUM_POS; i = i + 1) begin
                if (!pos_cap[i] && dut.MEM_WB_reg_write &&
                    dut.MEM_WB_pc == pos_pc[i] && dut.MEM_WB_rd == pos_rd[i]) begin
                    pos_val[i] = dut.wb_data;
                    pos_cap[i] = 1'b1;
                end
            end
            for (i = 0; i < NUM_NEG; i = i + 1) begin
                if (!neg_hit[i] && dut.MEM_WB_reg_write &&
                    dut.MEM_WB_pc == neg_pc[i] && dut.MEM_WB_rd == neg_rd[i]) begin
                    neg_hit[i] = 1'b1;
                end
            end
        end
    end
    localparam int NUM_POS = 56;
localparam int NUM_NEG = 10;
localparam int NUM_MEM = 4;

initial begin

    pos_pc[0]=32'h00000000; pos_rd[0]=1; pos_exp[0]=32'h0000000a; pos_desc[0]="test1: addi x1,x0,10";
    pos_pc[1]=32'h00000004; pos_rd[1]=2; pos_exp[1]=32'h00000003; pos_desc[1]="test1: addi x2,x0,3";
    pos_pc[2]=32'h00000008; pos_rd[2]=3; pos_exp[2]=32'h0000000d; pos_desc[2]="test1: add x3,x1,x2";
    pos_pc[3]=32'h0000000c; pos_rd[3]=4; pos_exp[3]=32'h00000007; pos_desc[3]="test1: sub x4,x1,x2";
    pos_pc[4]=32'h00000010; pos_rd[4]=5; pos_exp[4]=32'h00000002; pos_desc[4]="test1: and x5,x1,x2";
    pos_pc[5]=32'h00000014; pos_rd[5]=6; pos_exp[5]=32'h0000000b; pos_desc[5]="test1: or x6,x1,x2";
    pos_pc[6]=32'h00000018; pos_rd[6]=7; pos_exp[6]=32'h00000009; pos_desc[6]="test1: xor x7,x1,x2";
    pos_pc[7]=32'h0000001c; pos_rd[7]=8; pos_exp[7]=32'h00000050; pos_desc[7]="test1: sll x8,x1,x2";
    pos_pc[8]=32'h00000020; pos_rd[8]=9; pos_exp[8]=32'h00000001; pos_desc[8]="test1: srl x9,x1,x2";
    pos_pc[9]=32'h00000024; pos_rd[9]=10; pos_exp[9]=32'hfffffff8; pos_desc[9]="test1: addi x10,x0,-8";
    pos_pc[10]=32'h00000028; pos_rd[10]=11; pos_exp[10]=32'hffffffff; pos_desc[10]="test1: sra x11,x10,x2 (-8>>>3=-1)";
    pos_pc[11]=32'h0000002c; pos_rd[11]=12; pos_exp[11]=32'h00000001; pos_desc[11]="test1: slt x12,x2,x1 (3<10)";
    pos_pc[12]=32'h00000030; pos_rd[12]=13; pos_exp[12]=32'h00000000; pos_desc[12]="test1: sltu x13,x1,x2 (10<3u)";
    pos_pc[13]=32'h00000034; pos_rd[13]=14; pos_exp[13]=32'h00000001; pos_desc[13]="test1: sltiu x14,x0,1";
    pos_pc[14]=32'h00000038; pos_rd[14]=15; pos_exp[14]=32'h00000000; pos_desc[14]="test1: slti x15,x0,-1";
    pos_pc[15]=32'h0000003c; pos_rd[15]=16; pos_exp[15]=32'h00000002; pos_desc[15]="test1: andi x16,x1,3";
    pos_pc[16]=32'h00000040; pos_rd[16]=17; pos_exp[16]=32'h0000000b; pos_desc[16]="test1: ori x17,x1,1";
    pos_pc[17]=32'h00000044; pos_rd[17]=18; pos_exp[17]=32'h0000000b; pos_desc[17]="test1: xori x18,x1,1";
    pos_pc[18]=32'h00000048; pos_rd[18]=19; pos_exp[18]=32'h00000028; pos_desc[18]="test1: slli x19,x1,2";
    pos_pc[19]=32'h0000004c; pos_rd[19]=20; pos_exp[19]=32'h00000005; pos_desc[19]="test1: srli x20,x1,1";
    pos_pc[20]=32'h00000050; pos_rd[20]=21; pos_exp[20]=32'hfffffffc; pos_desc[20]="test1: srai x21,x10,1 (-8>>>1=-4)";
    pos_pc[21]=32'h00000054; pos_rd[21]=1; pos_exp[21]=32'hffffffff; pos_desc[21]="test2: addi x1,x0,-1";
    pos_pc[22]=32'h0000005c; pos_rd[22]=2; pos_exp[22]=32'hffffffff; pos_desc[22]="test2: lb x2,0(x0) sign-extended 0xFF";
    pos_pc[23]=32'h00000060; pos_rd[23]=3; pos_exp[23]=32'h000000ff; pos_desc[23]="test2: lbu x3,0(x0) zero-extended 0xFF";
    pos_pc[24]=32'h00000064; pos_rd[24]=4; pos_exp[24]=32'hffffffff; pos_desc[24]="test2: lh x4,0(x0) sign-extended 0xFFFF";
    pos_pc[25]=32'h00000068; pos_rd[25]=5; pos_exp[25]=32'h0000ffff; pos_desc[25]="test2: lhu x5,0(x0) zero-extended 0xFFFF";
    pos_pc[26]=32'h0000006c; pos_rd[26]=6; pos_exp[26]=32'hffffffff; pos_desc[26]="test2: lw x6,0(x0)";
    pos_pc[27]=32'h00000070; pos_rd[27]=7; pos_exp[27]=32'h0000007f; pos_desc[27]="test2: addi x7,x0,0x7F";
    pos_pc[28]=32'h00000078; pos_rd[28]=8; pos_exp[28]=32'h0000007f; pos_desc[28]="test2: lb x8,4(x0) positive byte";
    pos_pc[29]=32'h0000007c; pos_rd[29]=9; pos_exp[29]=32'h0000007f; pos_desc[29]="test2: lbu x9,4(x0) positive byte";
    pos_pc[30]=32'h00000080; pos_rd[30]=10; pos_exp[30]=32'h00000037; pos_desc[30]="test2: addi x10,x0,55";
    pos_pc[31]=32'h00000088; pos_rd[31]=11; pos_exp[31]=32'h00000037; pos_desc[31]="test2: lw x11,8(x0) store-data forwarding (EX/MEM)";
    pos_pc[32]=32'h0000008c; pos_rd[32]=12; pos_exp[32]=32'h00000063; pos_desc[32]="test2: addi x12,x0,99";
    pos_pc[33]=32'h00000094; pos_rd[33]=13; pos_exp[33]=32'h00000063; pos_desc[33]="test2: lw x13,12(x0) reload";
    pos_pc[34]=32'h00000098; pos_rd[34]=14; pos_exp[34]=32'h00000064; pos_desc[34]="test2: addi x14,x13,1 load-use hazard stall+forward";
    pos_pc[35]=32'h0000009c; pos_rd[35]=1; pos_exp[35]=32'h00000005; pos_desc[35]="test3: addi x1,x0,5";
    pos_pc[36]=32'h000000a0; pos_rd[36]=2; pos_exp[36]=32'h00000005; pos_desc[36]="test3: addi x2,x0,5";
    pos_pc[37]=32'h000000ac; pos_rd[37]=4; pos_exp[37]=32'h000000de; pos_desc[37]="test3: x4=222 correct branch target executed";
    pos_pc[38]=32'h000000b0; pos_rd[38]=5; pos_exp[38]=32'h00000001; pos_desc[38]="test3: x5=1 pipeline resumes normally after branch";
    pos_pc[39]=32'h000000b8; pos_rd[39]=6; pos_exp[39]=32'h0000004d; pos_desc[39]="test3: x6=77 not-taken branch falls through correctly";
    pos_pc[40]=32'h000000bc; pos_rd[40]=7; pos_exp[40]=32'h000000c0; pos_desc[40]="test3: x7=link register from jal (pc+4=188+4=192)";
    pos_pc[41]=32'h000000c4; pos_rd[41]=9; pos_exp[41]=32'h000001bc; pos_desc[41]="test3: x9=444 correct jal target executed";
    pos_pc[42]=32'h000000cc; pos_rd[42]=20; pos_exp[42]=32'h000000e0; pos_desc[42]="test4: x20 = absolute address of t4_target (224)";
    pos_pc[43]=32'h000000d0; pos_rd[43]=21; pos_exp[43]=32'h000000d4; pos_desc[43]="test4: x21=link register from jalr (pc+4=208+4=212)";
    pos_pc[44]=32'h000000e0; pos_rd[44]=23; pos_exp[44]=32'h000003e7; pos_desc[44]="test4: x23=999 jalr landed on correct target, not stuck in trap";
    pos_pc[45]=32'h000000e4; pos_rd[45]=24; pos_exp[45]=32'h12345000; pos_desc[45]="test5: lui x24,0x12345";
    pos_pc[46]=32'h000000e8; pos_rd[46]=25; pos_exp[46]=32'h000010e8; pos_desc[46]="test5: auipc x25,0x1 -> pc(232)+0x1000=0x10E8";
    pos_pc[47]=32'h000000ec; pos_rd[47]=1; pos_exp[47]=32'h00000001; pos_desc[47]="test6: addi x1,x0,1";
    pos_pc[48]=32'h000000f0; pos_rd[48]=2; pos_exp[48]=32'h00000002; pos_desc[48]="test6: add x2,x1,x1 (EX/MEM fwd)";
    pos_pc[49]=32'h000000f4; pos_rd[49]=3; pos_exp[49]=32'h00000003; pos_desc[49]="test6: add x3,x2,x1 (EX/MEM fwd)";
    pos_pc[50]=32'h000000f8; pos_rd[50]=4; pos_exp[50]=32'h00000005; pos_desc[50]="test6: add x4,x3,x2 (EX/MEM + MEM/WB fwd)";
    pos_pc[51]=32'h000000fc; pos_rd[51]=5; pos_exp[51]=32'h00000008; pos_desc[51]="test6: add x5,x4,x3 (EX/MEM + MEM/WB fwd)";
    pos_pc[52]=32'h00000100; pos_rd[52]=1; pos_exp[52]=32'h00000005; pos_desc[52]="test7: addi x1,x0,5";
    pos_pc[53]=32'h00000104; pos_rd[53]=2; pos_exp[53]=32'h00000005; pos_desc[53]="test7: addi x2,x0,5";
    pos_pc[54]=32'h00000114; pos_rd[54]=28; pos_exp[54]=32'h000001bc; pos_desc[54]="test7: x28=444 correct long-offset branch target executed";
    pos_pc[55]=32'h0000012c; pos_rd[55]=29; pos_exp[55]=32'h000003e7; pos_desc[55]="test8: x29=999 correct long-offset jal target executed";
    neg_pc[0]=32'h000000a8; neg_rd[0]=3; neg_desc[0]="test3: x3 delay-slot instr after TAKEN beq must be squashed";
    neg_pc[1]=32'h000000c0; neg_rd[1]=8; neg_desc[1]="test3: x8 delay-slot instr after JAL must be squashed";
    neg_pc[2]=32'h000000d4; neg_rd[2]=22; neg_desc[2]="test4: x22 delay-slot instr after JALR must be squashed";
    neg_pc[3]=32'h000000d8; neg_rd[3]=22; neg_desc[3]="test4: x22 second slot after JALR must be squashed";
    neg_pc[4]=32'h0000010c; neg_rd[4]=26; neg_desc[4]="test7: x26 wrong-path slot 1 after taken branch must be squashed";
    neg_pc[5]=32'h00000110; neg_rd[5]=27; neg_desc[5]="test7: x27 wrong-path slot 2 after taken branch must be squashed";
    neg_pc[6]=32'h0000011c; neg_rd[6]=26; neg_desc[6]="test8: x26 wrong-path slot 1 after jal must be squashed";
    neg_pc[7]=32'h00000120; neg_rd[7]=27; neg_desc[7]="test8: x27 wrong-path slot 2 after jal must be squashed";
    neg_pc[8]=32'h00000124; neg_rd[8]=26; neg_desc[8]="test8: x26 wrong-path slot 3 after jal must be squashed";
    neg_pc[9]=32'h00000128; neg_rd[9]=28; neg_desc[9]="test8: x28 wrong-path slot 4 after jal must be squashed";
    mem_idx[0]=0; mem_exp[0]=32'hffffffff; mem_desc[0]="test2: mem[word0] = 0xFFFFFFFF (sw x1,0(x0))";
    mem_idx[1]=1; mem_exp[1]=32'h0000007f; mem_desc[1]="test2: mem[word1] byte0 = 0x7F (sb x7,4(x0))";
    mem_idx[2]=2; mem_exp[2]=32'h00000037; mem_desc[2]="test2: mem[word2] = 55 (sw x10,8(x0), store-fwd)";
    mem_idx[3]=3; mem_exp[3]=32'h00000063; mem_desc[3]="test2: mem[word3] = 99 (sw x12,12(x0))";
end


    initial begin
        for (i = 0; i < NUM_POS; i = i + 1) pos_cap[i] = 1'b0;
        for (i = 0; i < NUM_NEG; i = i + 1) neg_hit[i] = 1'b0;
        for (i = 0; i < 256; i = i + 1) dut.my_dmem.data[i] = 32'h00000000;

        $display("=====================================================");
        $display(" Combined single-file RISC-V pipelined CPU testbench");
        $display("=====================================================");

        rst = 1;
        @(posedge clk);
        @(posedge clk);
        rst = 0;

        // 77 instructions, one load-use stall, several taken branches/jumps.
        // 200 cycles is comfortably more than enough to drain the pipeline
        // and land on the final halt loop.
        repeat (200) @(posedge clk);

        // ---------------- report ----------------
        $display("\n--- Positive checks (value must match) ---");
        for (i = 0; i < NUM_POS; i = i + 1) begin
            if (pos_cap[i] && pos_val[i] === pos_exp[i]) begin
                pass_count = pass_count + 1;
                $display("  [PASS] %-70s x%0d = 0x%08h", pos_desc[i], pos_rd[i], pos_val[i]);
            end else if (pos_cap[i]) begin
                fail_count = fail_count + 1;
                $display("  [FAIL] %-70s x%0d = 0x%08h  (expected 0x%08h)", pos_desc[i], pos_rd[i], pos_val[i], pos_exp[i]);
            end else begin
                fail_count = fail_count + 1;
                $display("  [FAIL] %-70s NEVER RETIRED (expected 0x%08h)", pos_desc[i], pos_exp[i]);
            end
        end

        $display("\n--- Negative checks (instruction must be squashed, never write back) ---");
        for (i = 0; i < NUM_NEG; i = i + 1) begin
            if (!neg_hit[i]) begin
                pass_count = pass_count + 1;
                $display("  [PASS] %-70s (correctly squashed)", neg_desc[i]);
            end else begin
                fail_count = fail_count + 1;
                $display("  [FAIL] %-70s (WRONG-PATH INSTRUCTION EXECUTED)", neg_desc[i]);
            end
        end

        $display("\n--- Data memory checks ---");
        for (i = 0; i < NUM_MEM; i = i + 1) begin
            if (dut.my_dmem.data[mem_idx[i]] === mem_exp[i]) begin
                pass_count = pass_count + 1;
                $display("  [PASS] %-70s mem[%0d] = 0x%08h", mem_desc[i], mem_idx[i], dut.my_dmem.data[mem_idx[i]]);
            end else begin
                fail_count = fail_count + 1;
                $display("  [FAIL] %-70s mem[%0d] = 0x%08h  (expected 0x%08h)", mem_desc[i], mem_idx[i], dut.my_dmem.data[mem_idx[i]], mem_exp[i]);
            end
        end

        $display("\n=====================================================");
        $display(" SUMMARY: %0d passed, %0d failed, %0d total", pass_count, fail_count, pass_count + fail_count);
        $display("=====================================================");

        $finish;
    end

    initial begin
        #100000;
        $display("WATCHDOG TIMEOUT -- simulation hung");
        $finish;
    end

endmodule