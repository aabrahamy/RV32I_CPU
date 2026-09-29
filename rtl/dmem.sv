module dmem (
    input logic clk,
    input logic [31:0] addr,
    input logic [31:0] wdata,
    input logic wen,
    output logic [31:0] rdata
);
    // data memory with 64 words of 32 bits each
    logic [31:0] data_mem [63:0]; // 64 words of 32 bits

    // read operation
    assign rdata = data_mem[addr[7:2]];

    // write operation
    always_ff @(posedge clk) begin
        if (wen) begin
            data_mem[addr[7:2]] <= wdata; // assuming word-aligned addresses
        end
    end

endmodule
