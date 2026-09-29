module imem (
    input logic [31:0] addr, // PC
    output logic [31:0] rdata // instruction at addr
);
    // instruction memory with 64 words of 32 bits each
    logic [31:0] instr_mem [63:0]; // 64 words of 32 bits

    // load the program at the start of simulation
    initial begin
        $readmemh("../../test/riscvtest.txt", instr_mem);
    end

    // read operation
    assign rdata = instr_mem[addr[7:2]]; // assuming word-aligned addresses

endmodule
