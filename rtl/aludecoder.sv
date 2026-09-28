module aludecoder (
    input logic op5, // bit 5 of the opcode
    input logic [2:0] funct3, // instruction bits [14:12]
    input logic funct7_b5, // instruction bit 30, 1 = sub for R-type
    input logic [1:0] aluop, // 2 bit ALU operation category from main decoder
    output logic [2:0] alucontrol // 3 bit operation select to ALU
);

    always_comb begin
        case (aluop)
            2'b00: alucontrol = 3'b000;
            2'b01: alucontrol = 3'b001;
            2'b10: begin
                case (funct3)
                    3'b000: alucontrol = (op5 & funct7_b5) ? 3'b001 : 3'b000;
                    3'b111: alucontrol = 3'b010;
                    3'b110: alucontrol = 3'b011;
                    3'b010: alucontrol = 3'b101
                    default: alucontrol = 3'bxxx;
                endcase
            end
            default: alucontrol = 3'bxxx;
        endcase
    end

endmodule