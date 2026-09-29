module regfile (
    input logic clk, // clock
    input logic [4:0] a1, // 5 bit address of rs1
    input logic [4:0] a2, // 5 bit address of rs2
    input logic [4:0] a3, // 5 bit address of rd
    input logic wen, // write enable for rd
    input logic [31:0] wdata, // data to write to rd
    output logic [31:0] rdata1, // data read from rs1
    output logic [31:0] rdata2 // data read from rs2
);

    logic [31:0] regs[31:0]; // 32 registers of 32 bits each

    // read data from registers
    // if the address is 0, return 0, else return the value in the register
    assign rdata1 = a1 ? regs[a1] : 32'b0;
    assign rdata2 = a2 ? regs[a2] : 32'b0;

    // write data to register on rising edge of clock if write enable is high
    always_ff @(posedge clk) begin
        if (wen && a3 != 5'b0) begin
            regs[a3] <= wdata;
        end
    end

endmodule

