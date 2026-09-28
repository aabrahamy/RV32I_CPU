module tb ();
    logic op5;
    logic [2:0] funct3;
    logic funct7_b5;
    logic [1:0] aluop;
    logic [2:0] alucontrol;

    aludecoder dut (
        .op5(op5),
        .funct3(funct3),
        .funct7_b5(funct7_b5),
        .aluop(aluop),
        .alucontrol(alucontrol)
    );

    initial begin
        // Test 1 - lw/sw (aluop 00) always add
        aluop = 2'b00;
        funct3 = 3'b010;
        op5 = 1'b0;
        funct7_b5 = 1'b0;
        #1;
        assert(alucontrol == 3'b000) else $fatal(1, "lw/sw failed: alucontrol = %b, expected 000", alucontrol);

        // Test 2 - aluop 00 ignores funct3 and funct7_b5 (sw with immediate bit 30 set)
        aluop = 2'b00;
        funct3 = 3'b010;
        op5 = 1'b1;
        funct7_b5 = 1'b1;
        #1;
        assert(alucontrol == 3'b000) else $fatal(1, "lw/sw don't-care failed: alucontrol = %b, expected 000", alucontrol);

        // Test 3 - beq (aluop 01) always sub
        aluop = 2'b01;
        funct3 = 3'b000;
        op5 = 1'b1;
        funct7_b5 = 1'b0;
        #1;
        assert(alucontrol == 3'b001) else $fatal(1, "beq failed: alucontrol = %b, expected 001", alucontrol);

        // Test 4 - R-type add (funct7_b5 = 0)
        aluop = 2'b10;
        funct3 = 3'b000;
        op5 = 1'b1;
        funct7_b5 = 1'b0;
        #1;
        assert(alucontrol == 3'b000) else $fatal(1, "add failed: alucontrol = %b, expected 000", alucontrol);

        // Test 5 - R-type sub (op5 = 1 and funct7_b5 = 1)
        aluop = 2'b10;
        funct3 = 3'b000;
        op5 = 1'b1;
        funct7_b5 = 1'b1;
        #1;
        assert(alucontrol == 3'b001) else $fatal(1, "sub failed: alucontrol = %b, expected 001", alucontrol);

        // Test 6 - addi with a small immediate (bit 30 = 0)
        aluop = 2'b10;
        funct3 = 3'b000;
        op5 = 1'b0;
        funct7_b5 = 1'b0;
        #1;
        assert(alucontrol == 3'b000) else $fatal(1, "addi failed: alucontrol = %b, expected 000", alucontrol);

        // Test 7 - addi with a negative immediate (bit 30 = 1) must still add, not sub
        aluop = 2'b10;
        funct3 = 3'b000;
        op5 = 1'b0;
        funct7_b5 = 1'b1;
        #1;
        assert(alucontrol == 3'b000) else $fatal(1, "addi negative imm failed: alucontrol = %b, expected 000", alucontrol);

        // Test 8 - and (R-type)
        aluop = 2'b10;
        funct3 = 3'b111;
        op5 = 1'b1;
        funct7_b5 = 1'b0;
        #1;
        assert(alucontrol == 3'b010) else $fatal(1, "and failed: alucontrol = %b, expected 010", alucontrol);

        // Test 9 - andi (I-type)
        aluop = 2'b10;
        funct3 = 3'b111;
        op5 = 1'b0;
        funct7_b5 = 1'b1;
        #1;
        assert(alucontrol == 3'b010) else $fatal(1, "andi failed: alucontrol = %b, expected 010", alucontrol);

        // Test 10 - or (R-type)
        aluop = 2'b10;
        funct3 = 3'b110;
        op5 = 1'b1;
        funct7_b5 = 1'b0;
        #1;
        assert(alucontrol == 3'b011) else $fatal(1, "or failed: alucontrol = %b, expected 011", alucontrol);

        // Test 11 - ori (I-type)
        aluop = 2'b10;
        funct3 = 3'b110;
        op5 = 1'b0;
        funct7_b5 = 1'b1;
        #1;
        assert(alucontrol == 3'b011) else $fatal(1, "ori failed: alucontrol = %b, expected 011", alucontrol);

        // Test 12 - slt (R-type)
        aluop = 2'b10;
        funct3 = 3'b010;
        op5 = 1'b1;
        funct7_b5 = 1'b0;
        #1;
        assert(alucontrol == 3'b101) else $fatal(1, "slt failed: alucontrol = %b, expected 101", alucontrol);

        // Test 13 - slti (I-type)
        aluop = 2'b10;
        funct3 = 3'b010;
        op5 = 1'b0;
        funct7_b5 = 1'b1;
        #1;
        assert(alucontrol == 3'b101) else $fatal(1, "slti failed: alucontrol = %b, expected 101", alucontrol);

        $display("ALL TESTS PASSED");
        $finish;
    end

endmodule
