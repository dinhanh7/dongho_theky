`timescale 1ns/1ps

module tb_datecounter;
    reg clk = 0;
    reg rst, dayroll, freeze, inc, dec;
    reg [1:0] sel;
    wire [4:0] dd;
    wire [3:0] mm;
    wire [13:0] yyyy;

    datecounter dut(
        .clk(clk), .rst(rst), .dayroll(dayroll),
        .freeze(freeze), .inc(inc), .dec(dec),
        .sel(sel), .dd(dd), .mm(mm), .yyyy(yyyy)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Helper task: print current date
    task print_date(input [255:0] msg);
        begin
            $display("%s: %02d/%02d/%04d", msg, dd, mm, yyyy);
        end
    endtask

    // Helper: wait for one clock
    task step;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    integer i; // Declare loop variable

    initial begin
        // Reset
        rst = 1; dayroll = 0; freeze = 0; inc = 0; dec = 0; sel = 2'b00;
        step;
        rst = 0;
        step;
        print_date("After reset");

        // Edit tăng ngày
        freeze = 1; sel = 2'b01; inc = 1; dec = 0;
        step;
        inc = 0;
        print_date("Edit +day");
        // Edit giảm ngày
        dec = 1;
        step;
        dec = 0;
        print_date("Edit -day");

        // Edit tăng tháng
        sel = 2'b10; inc = 1; dec = 0;
        step;
        inc = 0;
        print_date("Edit +month");
        // Edit giảm tháng
        dec = 1;
        step;
        dec = 0;
        print_date("Edit -month");

        // Edit tăng năm
        sel = 2'b11; inc = 1; dec = 0;
        step;
        inc = 0;
        print_date("Edit +year");
        // Edit giảm năm
        dec = 1;
        step;
        dec = 0;
        print_date("Edit -year");

        // Test năm nhuận: set 28/2/2024, dayroll -> 29/2/2024, dayroll -> 1/3/2024
        freeze = 1; sel = 2'b11; // set year 2024
        for (i = 0; i < (2024 - yyyy); i = i + 1) begin
            inc = 1; step; inc = 0; step;
        end
        sel = 2'b10; // set month 2
        for (i = 0; i < (2 - mm); i = i + 1) begin
            inc = 1; step; inc = 0; step;
        end
        sel = 2'b01; // set day 28
        for (i = 0; i < (28 - dd); i = i + 1) begin
            inc = 1; step; inc = 0; step;
        end
        freeze = 0; sel = 2'b00;
        print_date("Set 28/2/2024");
        // dayroll -> 29/2/2024
        dayroll = 1; step; dayroll = 0; step;
        print_date("After dayroll (leap): expect 29/2/2024");
        // dayroll -> 1/3/2024
        dayroll = 1; step; dayroll = 0; step;
        print_date("After dayroll (leap): expect 1/3/2024");

        // Test năm không nhuận: set 28/2/2023, dayroll -> 1/3/2023
        freeze = 1; sel = 2'b11;
        for (i = 0; i < (yyyy - 2023); i = i + 1) begin
            dec = 1; step; dec = 0; step;
        end
        sel = 2'b10;
        for (i = 0; i < (2 - mm); i = i + 1) begin
            inc = 1; step; inc = 0; step;
        end
        sel = 2'b01;
        for (i = 0; i < (28 - dd); i = i + 1) begin
            inc = 1; step; inc = 0; step;
        end
        freeze = 0; sel = 2'b00;
        print_date("Set 28/2/2023");
        dayroll = 1; step; dayroll = 0; step;
        print_date("After dayroll (non-leap): expect 1/3/2023");

        // Test dayroll nhiều lần: tăng ngày liên tục từ 30/12/2024 qua năm mới
        freeze = 1; sel = 2'b11;
        for (i = 0; i < (2024 - yyyy); i = i + 1) begin
            inc = 1; step; inc = 0; step;
        end
        sel = 2'b10;
        for (i = 0; i < (12 - mm); i = i + 1) begin
            inc = 1; step; inc = 0; step;
        end
        sel = 2'b01;
        for (i = 0; i < (30 - dd); i = i + 1) begin
            inc = 1; step; inc = 0; step;
        end
        freeze = 0; sel = 2'b00;
        print_date("Set 30/12/2024");
        for (i = 0; i < 3; i = i + 1) begin
            dayroll = 1; step; dayroll = 0; step;
            print_date("After dayroll");
        end

        $display("Testbench finished.");
        $finish;
    end
endmodule
