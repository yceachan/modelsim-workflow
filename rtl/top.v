module top (
    input  wire clk,
    input  wire rst_n,
    output wire led
);

    reg [3:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= 4'b0000;
        else
            counter <= counter + 1'b1;
    end

    assign led = counter[3];

endmodule
