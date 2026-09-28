// ALUControl encodings:
//   000 : add  (a + b) : used by add, addi, lw, sw
//   001 : sub  (a - b) : used by sub, beq
//   010 : and  (a & b) : used by and, andi
//   011 : or   (a | b) : used by or, ori
//   101 : slt  (a < b) : used by slt, slti (signed compare)

module alu (
    input  logic [31:0] a, // SrcA: rs1
    input  logic [31:0] b, // SrcB: rs2 or imm, from mux controlled by ALUSrc
    input  logic [2:0] alucontrol, // 3 bit operation select from ALU decoder
    output logic [31:0] result, // ALUResult
    output logic zero // 1 when result == 0, used for beq
);
    always_comb begin
        case (alucontrol)
            3'b000:  result = a + b; // add
            3'b001:  result = a - b; // subtract
            3'b010:  result = a & b; // and
            3'b011:  result = a | b; // or
            3'b101:  result = {31'b0, $signed(a) < $signed(b)}; // slt: 1 if a < b (signed)
            default: result = 32'bx;
        endcase
    end

    // zero flag is high when every bit of result is 0
    assign zero = (result == 32'b0);

endmodule
