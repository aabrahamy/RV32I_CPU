module tb ();
    logic [31:0] a, b;
    logic [2:0] alucontrol;
    logic [31:0] result;
    logic zero;

    alu dut (
        .a(a),
        .b(b),
        .alucontrol(alucontrol),
        .result(result),
        .zero(zero)
    );

    initial begin
        // Test 1 - Addition
        a = 32'd10;
        b = 32'd5;
        alucontrol = 3'b000;
        #1;
        assert(result == 32'd15) else $fatal("Addition failed: %0d + %0d != %0d", a, b, result);
        assert(zero == 1'b0) else $fatal("Zero flag failed: should be 0 for nonzero result");

        // Test 2 - Subtraction
        a = 32'd10;
        b = 32'd5;
        alucontrol = 3'b001;
        #1;
        assert(result == 32'd5) else $fatal("Subtraction failed: %0d - %0d != %0d", a, b, result);

        // Test 3 - Subtraction with a negative result (wraps to two's complement)
        a = 32'd5;
        b = 32'd10;
        alucontrol = 3'b001;
        #1;
        assert(result == 32'hFFFFFFFB) else $fatal("Negative subtraction failed: %0d - %0d != %0d", a, b, $signed(result));

        // Test 4 - Zero flag set when a == b (used by beq)
        a = 32'd7;
        b = 32'd7;
        alucontrol = 3'b001;
        #1;
        assert(result == 32'd0) else $fatal("Equal subtraction failed: %0d - %0d != %0d", a, b, result);
        assert(zero == 1'b1) else $fatal("Zero flag failed: should be 1 when result is 0");

        // Test 5 - AND
        a = 32'b1100;
        b = 32'b1010;
        alucontrol = 3'b010; 
        #1;
        assert(result == 32'b1000) else $fatal("AND failed: %b & %b != %b", a, b, result);

        // Test 6 - OR
        a = 32'b1100;
        b = 32'b1010;
        alucontrol = 3'b011; 
        #1;
        assert(result == 32'b1110) else $fatal("OR failed: %b | %b != %b", a, b, result);

        // Test 7 - SLT (signed less than), true
        a = -5; // signed representation of -5
        b = 3;
        alucontrol = 3'b101;
        #1;
        assert(result == 1) else $fatal("SLT failed: %0d < %0d != %0d", $signed(a), $signed(b), result);

        // Test 8 -SLT, false (a > b)
        a = 3;
        b = -5;
        alucontrol = 3'b101;
        #1;
        assert(result == 0) else $fatal("SLT failed: %0d < %0d != %0d", $signed(a), $signed(b), result);

        // Test 9 - SLT with two negative numbers
        a = -5;
        b = -3;
        alucontrol = 3'b101;
        #1;
        assert(result == 1) else $fatal("SLT failed: %0d < %0d != %0d", $signed(a), $signed(b), result);

        // Test 10 - SLT must be signed (-1 < 1), unsigned compare would give 0
        a = 32'hFFFFFFFF;
        b = 32'd1;
        alucontrol = 3'b101;
        #1;
        assert(result == 1) else $fatal("SLT signed failed: %0d < %0d != %0d", $signed(a), $signed(b), result);

        // Test 11 - SLT at the overflow edge, a - b overflows here
        a = 32'h80000000; // most negative 32-bit number
        b = 32'd1;
        alucontrol = 3'b101;
        #1;
        assert(result == 1) else $fatal("SLT overflow failed: %0d < %0d != %0d", $signed(a), $signed(b), result);

        $display("ALL TESTS PASSED");
        $finish;
    end

endmodule
