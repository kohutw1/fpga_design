// Testbench for div_5_detector module

`timescale 1 ns/1 ns

module top;
    // Declare DUT I/O
    logic clk = 1'd0;
    logic rst_n = 1'd1;

    logic in_bit;

    logic div_5;

    logic [63:0] div_5_model = 63'd0;
    int cycle=0;

    localparam CLK_PERIOD      = 2;
    localparam CLK_PERIOD_BY_2 = CLK_PERIOD/2;

    // Specify the number of cycles, where a single random bit
    // is shifted into the LSB position on each cycle
    int NUM_CYCLES;

    initial begin
        if($value$plusargs("NUM_CYCLES=%d", NUM_CYCLES) && (NUM_CYCLES != "")) begin end
        else begin $fatal(0, "Must specify a value for NUM_CYCLES"); end
    end

    // Generate a clock
    initial forever #CLK_PERIOD_BY_2 clk = !clk;

    // Instantiate the DUT
    div_5_detector dut(.*);

    // Drive stimulus into the DUT and compare against model
    initial begin
        #10 rst_n = 1'd0; // Enter reset
        #10 rst_n = 1'd1; // Exit reset

        $display("========== START VERIFICATION ==========");

        repeat(NUM_CYCLES) begin
            // Drive random value
            @(negedge clk) in_bit = $random;

            // I'd use an assertion here, but Icarus Verilog doesn't support them yet
            if(((div_5_model % 5) == 0) && dut.first_1_seen) begin
                if( div_5) begin display_status_msg("pass", div_5);
                end else   begin display_status_msg("fail", div_5); end
            end else begin
                if(!div_5) begin display_status_msg("pass", div_5);
                end else   begin display_status_msg("fail", div_5); end
            end

            // Shift into register to verify div_5
            @(posedge clk) div_5_model = (div_5_model << 1) | in_bit;

            cycle++;
        end

        $display("========== END VERIFICATION: TEST PASSED! ==========");

        $finish;
    end

    // Dump waves
    initial $dumpvars;

    task display_status_msg(input string status, input logic div_5);
        string div_5_string;

        if(div_5) begin
            div_5_string = " <== Divisible by 5";
        end else begin
            div_5_string = "";
        end

        if(status == "pass") begin
            $display(   "PASS: t=%3t ns (cycle=%2d): div_5=%b, div_5_model=%0d%s", $time, cycle, div_5, div_5_model, div_5_string);
        end else if(status == "fail") begin
            $fatal  (0, "FAIL: t=%3t ns (cycle=%2d): div_5=%b, div_5_model=%0d"  , $time, cycle, div_5, div_5_model);
        end else begin
            $fatal  (0, "Illegal status");
        end
    endtask
endmodule
