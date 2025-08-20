`timescale 1ns/1ps

module tb_timecounter;
    reg clk = 0, rst = 0;
    reg tick1Hz = 0;
    reg freeze = 0;
    reg inc = 0, dec = 0;
    reg [1:0] sel = 2'b00;
    wire [5:0] ss, mm;
    wire [4:0] hh;
    wire dayroll;

    // Instantiate the timecounter module
    timecounter dut(
        .clk(clk), .rst(rst),
        .tick1Hz(tick1Hz),
        .freeze(freeze),
        .inc(inc), .dec(dec),
        .sel(sel),
        .ss(ss), .mm(mm), .hh(hh),
        .dayroll(dayroll)
    );

    // Clock and tick generation
    always #10 clk = ~clk;
    always #100 tick1Hz = ~tick1Hz;

    // Increment and decrement button simulation tasks
    task press_inc;
        begin inc = 1; #20; inc = 0; #80; end
    endtask
    task press_dec;
        begin dec = 1; #20; dec = 0; #80; end
    endtask

    initial begin
        // Reset
        rst = 1; #50; rst = 0; #50;

        // Đếm đến 1 phút 30 giây
        freeze = 0; sel = 2'b00;
        $display("Bắt đầu đếm đến 1 phút 30 giây...");
        repeat(90) @(posedge tick1Hz);
        $display("Tới %02d:%02d:%02d", hh, mm, ss);

        // Vào chế độ sửa, chọn sel=01 (giây), tăng 2 lần
        freeze = 1; sel = 2'b01;
        $display("Chỉnh giây, tăng 2 lần");
        press_inc;
        press_inc;
        $display("Sau chỉnh giây: %02d:%02d:%02d", hh, mm, ss);

        // Chuyển sang sel=10 (phút), giảm 2 lần
        sel = 2'b10;
        $display("Chỉnh phút, giảm 2 lần");
        press_dec;
        press_dec;
        $display("Sau chỉnh phút: %02d:%02d:%02d", hh, mm, ss);

        // Chỉnh giờ, tăng 1 lần
        sel = 2'b11;
        $display("Chỉnh giờ, tăng 1 lần");
        press_inc;
        $display("Sau chỉnh giờ: %02d:%02d:%02d", hh, mm, ss);

        // Kết thúc
        freeze = 0; sel = 2'b00;
        #200;
        $finish;
    end
endmodule
