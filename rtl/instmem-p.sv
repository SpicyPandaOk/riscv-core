module instmem (
    input [31:0] addr,
    output [31:0] instr
);
    reg [31:0] rom [0:255];

    initial begin
        $readmemh("instmemp.hex", rom);
    end

    assign instr = rom[addr[9:2]];
endmodule
