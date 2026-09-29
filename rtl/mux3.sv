module mux3 (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [31:0] c,
    input logic [1:0] sel,
    output logic [31:0] y
);
    // 3-to-1 multiplexer logic
    always_comb begin
        case (sel)
            2'b00: y = a; 
            2'b01: y = b; 
            2'b10: y = c; 
            default : y = 32'bx;
        endcase
    end

endmodule
