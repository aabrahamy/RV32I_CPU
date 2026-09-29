module tb ();
    logic [31:0] addr;
    logic [31:0] rdata;

    // copy of the program, loaded from the same file imem uses
    logic [31:0] expected [63:0];

    imem dut (
        .addr(addr),
        .rdata(rdata)
    );

    initial begin
        $readmemh("../../test/riscvtest.txt", expected);

        // Test 1 - Program was loaded (first instruction is not empty)
        addr = 32'd0;
        #1;
        assert(rdata != 32'd0) else $fatal(1, "No program loaded: imem[0] = 0, is test/riscvtest.txt empty?");

        // Test 2 - Every word matches the file, byte address i*4 reads line i
        for (int i = 0; i < 64; i++) begin
            addr = i * 4;
            #1;
            assert(rdata == expected[i]) else $fatal(1, "Read failed at addr %0d: rdata = %h, expected %h", addr, rdata, expected[i]);
        end

        // Test 3 - Byte address 4 reads the second line, not the fifth
        addr = 32'd4;
        #1;
        assert(rdata == expected[1]) else $fatal(1, "Byte to word failed: addr 4 read %h, expected %h", rdata, expected[1]);

        $display("ALL TESTS PASSED");
        $finish;
    end

endmodule
