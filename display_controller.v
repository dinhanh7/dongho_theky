module display_controller(
    input [5:0] ss,
    input [5:0] mm,
    input [4:0] hh,
    input [4:0] dd,
    input [3:0] month,
    input [13:0] yyyy,
    input blink2Hz,
    input set_mode,
    input [1:0] field_sel,
    input display_sel,
    input mode,//hien thi tiem hay date
    output [6:0] seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7 
);

wire [7:0] bcd_ss, bcd_mm, bcd_hh, bcd_dd, bcd_month;
wire [15:0] bcd_yyyy;

    dddb #(.BIN_WIDTH(6), .BCD_DIGITS(2)) u_dddb_ss (
        .bin(ss), .bcd(bcd_ss)
    );
    dddb #(.BIN_WIDTH(6), .BCD_DIGITS(2)) u_dddb_mm (
        .bin(mm), .bcd(bcd_mm)
    );
    dddb #(.BIN_WIDTH(5), .BCD_DIGITS(2)) u_dddb_hh (
        .bin(hh), .bcd(bcd_hh)
    );
    dddb #(.BIN_WIDTH(5), .BCD_DIGITS(2)) u_dddb_dd (
        .bin(dd), .bcd(bcd_dd)
    );
    dddb #(.BIN_WIDTH(4), .BCD_DIGITS(2)) u_dddb_month (
        .bin(month), .bcd(bcd_month)
    );
    dddb #(.BIN_WIDTH(14), .BCD_DIGITS(4)) u_dddb_yyyy (
        .bin(yyyy), .bcd(bcd_yyyy)
    );

    wire [3:0] digit0, digit1, digit2, digit3, digit4, digit5, digit6, digit7;

    assign {digit7, digit6, digit5, digit4, digit3, digit2, digit1, digit0} =
        (mode == 1'b0) ?
        {4'b1111, 4'b1111, bcd_hh[7:4], bcd_hh[3:0], bcd_mm[7:4], bcd_mm[3:0], bcd_ss[7:4], bcd_ss[3:0]} :
            // Hiển thị ngày tháng
        {bcd_dd[7:4], bcd_dd[3:0], bcd_month[7:4], bcd_month[3:0],bcd_yyyy[15:12], bcd_yyyy[11:8], bcd_yyyy[7:4], bcd_yyyy[3:0] };

    // Blink signals for each field
    wire blink_sec   = set_mode & (field_sel==2'b01) & ~display_sel & blink2Hz;
    wire blink_min   = set_mode & (field_sel==2'b10) & ~display_sel & blink2Hz;
    wire blink_hour  = set_mode & (field_sel==2'b11) & ~display_sel & blink2Hz;
    wire blink_day   = set_mode & (field_sel==2'b01) &  display_sel & blink2Hz;
    wire blink_month = set_mode & (field_sel==2'b10) &  display_sel & blink2Hz;
    wire blink_year  = set_mode & (field_sel==2'b11) &  display_sel & blink2Hz;

    seven_segment u_seg0(.hex_digit(digit0), .blink(display_sel ? blink_year : blink_sec), .seg_data(seg0));
    seven_segment u_seg1(.hex_digit(digit1), .blink(display_sel ? blink_year : blink_sec), .seg_data(seg1));
    seven_segment u_seg2(.hex_digit(digit2), .blink(display_sel ? blink_year : blink_min), .seg_data(seg2));
    seven_segment u_seg3(.hex_digit(digit3), .blink(display_sel ? blink_year : blink_min), .seg_data(seg3));
    seven_segment u_seg4(.hex_digit(digit4), .blink(display_sel ? blink_month : blink_hour), .seg_data(seg4));
    seven_segment u_seg5(.hex_digit(digit5), .blink(display_sel ? blink_month : blink_hour), .seg_data(seg5));
    seven_segment u_seg6(.hex_digit(digit6), .blink(
        display_sel ? (blink_day) : 1'b0
    ), .seg_data(seg6));
    seven_segment u_seg7(.hex_digit(digit7), .blink(
        display_sel ? (blink_day) : 1'b0
    ), .seg_data(seg7));

endmodule
