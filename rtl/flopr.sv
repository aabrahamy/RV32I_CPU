module flopr (
    input logic clk,
    input logic rst, // force q to zero
    input logic [31:0] d, // input data, PCNext
    output logic [31:0] q // output data, PC
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 32'b0; // reset output to zero
        end else begin
            q <= d; // capture input data on clock edge
        end
    end
endmodule
