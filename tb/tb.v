`timescale 1ns/1ps

module tb;

    reg  clk;
    reg  rst_n;
    wire led;
    reg  seen_led_high;
    reg  seen_led_low_after_high;

    top dut (
        .clk   (clk),
        .rst_n (rst_n),
        .led   (led)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (rst_n && led)
            seen_led_high = 1'b1;
        if (rst_n && seen_led_high && !led)
            seen_led_low_after_high = 1'b1;
    end

    initial begin
        rst_n = 1'b0;
        seen_led_high = 1'b0;
        seen_led_low_after_high = 1'b0;

        #20;
        rst_n = 1'b1;

        #200;
        if (seen_led_high && seen_led_low_after_high)
            $display("PASS: LED blink simulation completed");
        else
            $error("FAIL: LED did not toggle as expected");

        $finish;
    end

endmodule
