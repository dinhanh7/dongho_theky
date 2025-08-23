module top_time_display(
	input clk, rst_n,
	input display_sel, // 1: hiển thị giờ, 0: hiển thị ngày tháng năm (nếu cần)
	input set_mode, //che do chinh sua
	input tang,
	input giam,
	input [1:0] field_sel,//chon truong chinh sua
	output [6:0] seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7,
	output led1
);

	wire clk1Hz;
	assign led1=clk1Hz;
	wire blink2Hz;
	// Chia tần số xung clock 1Hz
	clkdivider u_clkdiv(
		.clk(clk),
		.rst_n(rst_n),
		.clk1Hz(clk1Hz),
		.blink2Hz(blink2Hz)
	);
    // ---------------- Debounce CE 1 kHz ----------------
    wire deb_ce;
    ce_gen #(.CLK_HZ(50_000_000), .CE_HZ(1000)) u_debce(
        .clk(clk), .rst_n(rst_n), .ce(deb_ce)
    );

	// ---------------- Buttons (active-low) ----------------
    // wire sel_p,   
	
    // btn_deb_onepulse_ce #(.STABLE_MS(20), .CE_HZ(1000)) u_sel  (
    //     .clk(clk), .rst_n(rst_n), .sample_ce(deb_ce),
    //     .btn_n(KEY[0]), .pressed(), .press_pulse(sel_p), .release_pulse()
    // );
	wire up_p,   down_p;
    btn_deb_onepulse_ce #(.STABLE_MS(20), .CE_HZ(1000)) u_up   (
        .clk(clk), .rst_n(rst_n), .sample_ce(deb_ce),
        .btn_n(tang), .pressed(),  .press_pulse(up_p),  .release_pulse()
    );
    btn_deb_onepulse_ce #(.STABLE_MS(20), .CE_HZ(1000)) u_down (
        .clk(clk), .rst_n(rst_n), .sample_ce(deb_ce),
        .btn_n(giam), .pressed(),  .press_pulse(down_p),  .release_pulse()
    );

    // ---------------- Counters TIME ----------------
	wire inc_sec_auto= ~set_mode & clk1Hz;
    wire [5:0] sec;  wire c_min;
    counter_mod60 u_sec (
        .clk(clk), .rst_n(rst_n),
        .inc_auto(inc_sec_auto),
        .inc_manual(set_mode & (field_sel==2'b01) & ~display_sel & up_p), // TIME + d/s = seconds
        .dec_manual(set_mode & (field_sel==2'b01) & ~display_sel & down_p),
        .value(sec), .carry_out(c_min)
    );

    wire [5:0] min;  wire c_hour;
    counter_mod60 u_min (
        .clk(clk), .rst_n(rst_n),
        .inc_auto(c_min),
        .inc_manual(set_mode & (field_sel==2'b10) & ~display_sel & up_p), // TIME + m/m = minutes
        .dec_manual(set_mode & (field_sel==2'b10) & ~display_sel & down_p),
        .value(min), .carry_out(c_hour)
    );

    wire [4:0] hour; wire c_day;
    counter_mod24 u_hour (
        .clk(clk), .rst_n(rst_n),
        .inc_auto(c_hour),
        .inc_manual(set_mode & (field_sel==2'b11) & ~display_sel & up_p), // TIME + y/h = hours
        .dec_manual(set_mode & (field_sel==2'b11) & ~display_sel & down_p),
        .value(hour), .carry_out(c_day)
    );


    // ---------------- Ngày / tháng / năm (+leap) ----------------

    
    wire [5:0]  dim;
    wire [5:0]  day;   
	wire c_month;
    counter_ngay u_day(
        .clk(clk), .rst_n(rst_n),
        .inc_auto(c_day),
        .inc_manual(set_mode & (field_sel==2'b01) &  display_sel & up_p), // DATE + d/s = day
        .dec_manual(set_mode & (field_sel==2'b01) &  display_sel & down_p),
        .dim(dim), .value(day), .carry_out(c_month)
    );
    
    wire [3:0]  month; 
	wire c_year;
	wire leap;
    counter_thang u_mon(
        .clk(clk), .rst_n(rst_n),
        .inc_auto(c_month),
        .inc_manual(set_mode & (field_sel==2'b10) &  display_sel & up_p), // DATE + m/m = month
        .dec_manual(set_mode & (field_sel==2'b10) &  display_sel & down_p),
        .leap(leap),
        .value(month), .carry_out(c_year),
		.dim(dim)
    );
    wire [13:0] year;   // từ counter_year_10000_leap
    counter_nam u_year(
        .clk(clk), .rst_n(rst_n),
        .inc_auto(c_year),
        .inc_manual(set_mode & (field_sel==2'b11) &  display_sel & up_p), // DATE + y/h = year
        .dec_manual(set_mode & (field_sel==2'b11) &  display_sel & down_p),
        .value(year), .leap(leap)
    );

	// Hiển thị ra 8 LED 7 đoạn
	display_controller u_disp(
		.ss(sec),
		.mm(min),
		.hh(hour),
		.dd(day),
		.month(month),
		.yyyy(year),
		.blink2Hz(blink2Hz),
		.set_mode(set_mode),
		.field_sel(field_sel),
		.display_sel(display_sel),
		.mode(display_sel),
		.seg0(seg0), .seg1(seg1), .seg2(seg2), .seg3(seg3),
		.seg4(seg4), .seg5(seg5), .seg6(seg6), .seg7(seg7)
	);

endmodule
