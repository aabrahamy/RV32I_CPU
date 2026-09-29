module tb ();
    logic clk;
    logic [4:0] a1, a2, a3;
    logic wen;
    logic [31:0] wdata;
    logic [31:0] rdata1, rdata2;

    regfile dut (
        .clk(clk),
        .a1(a1),
        .a2(a2),
        .a3(a3),
        .wen(wen),
        .wdata(wdata),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    // 10 time unit clock period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // write data to a register on the next rising edge, then turn write enable off
    task automatic write_reg(input logic [4:0] addr, input logic [31:0] data);
        a3 = addr;
        wdata = data;
        wen = 1'b1;
        @(posedge clk);
        #1;
        wen = 1'b0;
    endtask

    initial begin
        a1 = 5'd0;
        a2 = 5'd0;
        a3 = 5'd0;
        wen = 1'b0;
        wdata = 32'd0;
        @(negedge clk);

        // Test 1 - Write x5, read it back on port 1
        write_reg(5'd5, 32'hDEADBEEF);
        a1 = 5'd5;
        #1;
        assert(rdata1 == 32'hDEADBEEF) else $fatal(1, "Write/read x5 failed: rdata1 = %h, expected DEADBEEF", rdata1);

        // Test 2 - Read the same register on port 2
        a2 = 5'd5;
        #1;
        assert(rdata2 == 32'hDEADBEEF) else $fatal(1, "Port 2 read x5 failed: rdata2 = %h, expected DEADBEEF", rdata2);

        // Test 3 - Both ports read different registers at the same time
        write_reg(5'd6, 32'h12345678);
        a1 = 5'd5;
        a2 = 5'd6;
        #1;
        assert(rdata1 == 32'hDEADBEEF) else $fatal(1, "Dual read failed: rdata1 = %h, expected DEADBEEF", rdata1);
        assert(rdata2 == 32'h12345678) else $fatal(1, "Dual read failed: rdata2 = %h, expected 12345678", rdata2);

        // Test 4 - No write when wen is 0
        a3 = 5'd5;
        wdata = 32'hFFFFFFFF;
        wen = 1'b0;
        @(posedge clk);
        #1;
        a1 = 5'd5;
        #1;
        assert(rdata1 == 32'hDEADBEEF) else $fatal(1, "Write enable failed: x5 changed to %h with wen = 0", rdata1);

        // Test 5 - Write only happens on the clock edge, not before
        @(negedge clk);
        a3 = 5'd7;
        wdata = 32'hCAFEF00D;
        wen = 1'b1;
        a1 = 5'd7;
        #1;
        assert(rdata1 != 32'hCAFEF00D) else $fatal(1, "Write happened before the clock edge");
        @(posedge clk);
        #1;
        wen = 1'b0;
        assert(rdata1 == 32'hCAFEF00D) else $fatal(1, "Write on clock edge failed: rdata1 = %h, expected CAFEF00D", rdata1);

        // Test 6 - Overwrite an existing value
        write_reg(5'd5, 32'h00000001);
        a1 = 5'd5;
        #1;
        assert(rdata1 == 32'h00000001) else $fatal(1, "Overwrite failed: rdata1 = %h, expected 00000001", rdata1);

        // Test 7 - Lowest and highest writable registers (x1 and x31)
        write_reg(5'd1, 32'hAAAAAAAA);
        write_reg(5'd31, 32'h55555555);
        a1 = 5'd1;
        a2 = 5'd31;
        #1;
        assert(rdata1 == 32'hAAAAAAAA) else $fatal(1, "x1 failed: rdata1 = %h, expected AAAAAAAA", rdata1);
        assert(rdata2 == 32'h55555555) else $fatal(1, "x31 failed: rdata2 = %h, expected 55555555", rdata2);

        // Test 8 - Writes to x0 are ignored, x0 always reads 0 on both ports
        write_reg(5'd0, 32'hFFFFFFFF);
        a1 = 5'd0;
        a2 = 5'd0;
        #1;
        assert(rdata1 == 32'd0) else $fatal(1, "x0 port 1 failed: rdata1 = %h, expected 0", rdata1);
        assert(rdata2 == 32'd0) else $fatal(1, "x0 port 2 failed: rdata2 = %h, expected 0", rdata2);

        $display("ALL TESTS PASSED");
        $finish;
    end

endmodule
