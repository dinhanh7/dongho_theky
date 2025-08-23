module dddb #(
    parameter BIN_WIDTH  = 8,
    parameter BCD_DIGITS = 3               // number of output BCD digits (each 0..9)
) (
    input  wire [BIN_WIDTH-1:0]     bin,
    output reg  [4*BCD_DIGITS-1:0]  bcd
);
    integer i;
    reg [3:0] bcd_thousands;
    reg [3:0] bcd_hundreds;
    reg [3:0] bcd_tens;
    reg [3:0] bcd_ones;
    reg [BIN_WIDTH-1:0] binary;

    always @(*) begin
            bcd_thousands = 4'd0;
            bcd_hundreds = 4'd0;
            bcd_tens = 4'd0;
            bcd_ones = 4'd0;
            binary = bin;

            for (i = BIN_WIDTH-1; i >= 0; i = i - 1) begin
                // Add 3 if >= 5
                if (bcd_thousands >= 5) bcd_thousands = bcd_thousands + 4'd3;
                if (bcd_hundreds >= 5)  bcd_hundreds  = bcd_hundreds  + 4'd3;
                if (bcd_tens >= 5)      bcd_tens      = bcd_tens      + 4'd3;
                if (bcd_ones >= 5)      bcd_ones      = bcd_ones      + 4'd3;

                // Shift left all BCD digits, MSB in from lower digit, LSB in from binary
                bcd_thousands = {bcd_thousands[2:0], bcd_hundreds[3]};
                bcd_hundreds  = {bcd_hundreds[2:0], bcd_tens[3]};
                bcd_tens      = {bcd_tens[2:0], bcd_ones[3]};
                bcd_ones      = {bcd_ones[2:0], binary[i]};

            // Pack BCD digits into output
            case (BCD_DIGITS)
                4: bcd <= {bcd_thousands, bcd_hundreds, bcd_tens, bcd_ones};
                3: bcd <= {bcd_hundreds, bcd_tens, bcd_ones};
                2: bcd <= {bcd_tens, bcd_ones};
                1: bcd <= {bcd_ones};
                default: bcd <= 0;
            endcase
        end
    end
endmodule