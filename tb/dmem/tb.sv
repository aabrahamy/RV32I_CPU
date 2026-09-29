module tb ();
    logic clk;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic wen;
    logic [31:0] rdata;

    dmem dut (
        .clk(clk),
        .addr(addr),
        .wdata(wdata),
        .wen(wen),
        .rdata(rdata)
    );

    // 10 time unit clock period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // write data to an address on the next rising edge, then turn write enable off
    task automatic write_mem(input logic [31:0] a, input logic [31:0] data);
        addr = a;
        wdata = data;
        wen = 1'b1;
        @(posedge clk);
        #1;
        wen = 1'b0;
    endtask

    initial begin
        addr = 32'd0;
        wdata = 32'd0;
        wen = 1'b0;
        @(negedge clk);

        // Test 1 - Write a word, read it back (sw then lw)
        write_mem(32'd0, 32'hDEADBEEF);
        addr = 32'd0;
        #1;
        assert(rdata == 32'hDEADBEEF) else $fatal(1, "Write/read addr 0 failed: rdata = %h, expected DEADBEEF", rdata);

        // Test 2 - Byte address 4 is word 1, separate from word 0
        write_mem(32'd4, 32'h12345678);
        addr = 32'd4;
        #1;
        assert(rdata == 32'h12345678) else $fatal(1, "Write/read addr 4 failed: rdata = %h, expected 12345678", rdata);
        addr = 32'd0;
        #1;
        assert(rdata == 32'hDEADBEEF) else $fatal(1, "Addr 0 changed after writing addr 4: rdata = %h, expected DEADBEEF", rdata);

        // Test 3 - Last word (byte address 252 = word 63)
        write_mem(32'd252, 32'hCAFEF00D);
        addr = 32'd252;
        #1;
        assert(rdata == 32'hCAFEF00D) else $fatal(1, "Write/read addr 252 failed: rdata = %h, expected CAFEF00D", rdata);

        // Test 4 - No write when wen is 0
        addr = 32'd0;
        wdata = 32'hFFFFFFFF;
        wen = 1'b0;
        @(posedge clk);
        #1;
        assert(rdata == 32'hDEADBEEF) else $fatal(1, "Write enable failed: addr 0 changed to %h with wen = 0", rdata);

        // Test 5 - Write only happens on the clock edge, not before
        @(negedge clk);
        addr = 32'd8;
        wdata = 32'hA5A5A5A5;
        wen = 1'b1;
        #1;
        assert(rdata != 32'hA5A5A5A5) else $fatal(1, "Write happened before the clock edge");
        @(posedge clk);
        #1;
        wen = 1'b0;
        assert(rdata == 32'hA5A5A5A5) else $fatal(1, "Write on clock edge failed: rdata = %h, expected A5A5A5A5", rdata);

        // Test 6 - Byte address 64 is word 16, it must not overwrite word 0
        write_mem(32'd64, 32'h0BADC0DE);
        addr = 32'd64;
        #1;
        assert(rdata == 32'h0BADC0DE) else $fatal(1, "Write/read addr 64 failed: rdata = %h, expected 0BADC0DE", rdata);
        addr = 32'd0;
        #1;
        assert(rdata == 32'hDEADBEEF) else $fatal(1, "Addr 0 changed after writing addr 64: rdata = %h, expected DEADBEEF", rdata);

        // Test 7 - Overwrite an existing value
        write_mem(32'd4, 32'h00000001);
        addr = 32'd4;
        #1;
        assert(rdata == 32'h00000001) else $fatal(1, "Overwrite failed: rdata = %h, expected 00000001", rdata);

        $display("ALL TESTS PASSED");
        $finish;
    end

endmodule
