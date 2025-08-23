// Output bit order: a b c d e f g (0 = sáng, 1 = tắt)
module seven_segment(
    input      [3:0] hex_digit,  // giá trị hexa cần hiển thị
    input blink,
    output reg [6:0] seg_data    // a b c d e f g (active-low)
);
    always @(hex_digit or blink) begin
        if (blink) seg_data = 7'b1111111; // blink: all segments off
        else begin
        case (hex_digit)
            4'b0000: seg_data = 7'b0000001;
            4'b0001: seg_data = 7'b1001111;
            4'b0010: seg_data = 7'b0010010;
            4'b0011: seg_data = 7'b0000110;
            4'b0100: seg_data = 7'b1001100;
            4'b0101: seg_data = 7'b0100100;
            4'b0110: seg_data = 7'b0100000;
            4'b0111: seg_data = 7'b0001111;
            4'b1000: seg_data = 7'b0000000;
            4'b1001: seg_data = 7'b0001100;
            default: seg_data = 7'b1111111; // off
        endcase
    end
    end
endmodule