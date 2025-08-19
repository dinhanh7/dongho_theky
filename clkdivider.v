module clkdivider(
    input clk,
    output reg clk1Hz,
    output reg clk2Hz,
    output reg clkref // ~4kHz dùng quét LED
);
    reg [25:0] cnt1Hz = 0;
    reg [13:0] cntref = 0;

    always @(posedge clk) begin
        // Chia clock 50MHz xuống 1Hz và 2Hz
        if(cnt1Hz == 25_000_000-1) begin
            cnt1Hz <= 0;
            clk1Hz <= ~clk1Hz;
            clk2Hz <= ~clk2Hz;
        end else begin
            cnt1Hz <= cnt1Hz + 1;
        end

        // Chia clock 50MHz xuống ~4kHz để quét LED
        if(cntref == 6_250-1) begin
            cntref <= 0;
            clkref <= ~clkref;
        end else begin
            cntref <= cntref + 1;
        end
    end
endmodule