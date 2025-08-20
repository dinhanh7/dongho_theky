module datecounter(
    input clk,
    input rst,
    input dayroll,
    input freeze,
    input inc, dec,
    input [1:0] sel,
    output reg [4:0] dd,      // 0-31
    output reg [3:0] mm,      // 0-12
    output reg [13:0] yyyy    // 0-9999
);

    reg [4:0] maxd;
    reg leap;
    reg [6:0] rem100;   // 0..99
    reg [8:0] rem400;   // 0..399

    // add temporaries at module scope (cannot declare inside procedural blocks)
    integer tmp;
    integer tmp2;
    integer tmp3;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            dd <= 5'd1;
            mm <= 4'd1;
            yyyy <= 14'd2024;
        end else begin
            // Tính năm nhuận và số ngày tối đa của tháng hiện tại
            // Không dùng /, %, function: tính phần dư bằng trừ lặp

            // rem100
            tmp = yyyy;
            while (tmp >= 100) tmp = tmp - 100;
            rem100 = tmp; // 0..99

            // rem400
            tmp = yyyy;
            while (tmp >= 400) tmp = tmp - 400;
            rem400 = tmp; // 0..399

            // divisible by 4 check via low bits
            if ((yyyy[1:0] == 2'b00) && (rem100 != 7'd0)) leap = 1'b1;
            else if (rem400 == 0) leap = 1'b1;
            else leap = 1'b0;

            case(mm)
                4'd1,4'd3,4'd5,4'd7,4'd8,4'd10,4'd12: maxd = 5'd31;
                4'd4,4'd6,4'd9,4'd11: maxd = 5'd30;
                4'd2: maxd = leap ? 5'd29 : 5'd28;
                default: maxd = 5'd31;
            endcase

            if(!freeze) begin
                if(dayroll) begin
                    if(dd == maxd) begin
                        dd <= 5'd1;
                        if(mm == 4'd12) begin
                            mm <= 4'd1;
                            if(yyyy == 14'd9999) yyyy <= 14'd0;
                            else yyyy <= yyyy + 1;
                        end else begin
                            mm <= mm + 1;
                        end
                    end else begin
                        dd <= dd + 1;
                    end
                end
            end else begin
                case(sel)
                    2'b01: begin // chỉnh ngày
                        if(inc) begin
                            if(dd == maxd) dd <= 5'd1;
                            else dd <= dd + 1;
                        end
                        if(dec) begin
                            if(dd == 5'd1) dd <= maxd;
                            else dd <= dd - 1;
                        end
                    end
                    2'b10: begin // chỉnh tháng
                        if(inc) begin
                            if(mm == 4'd12) mm <= 4'd1;
                            else mm <= mm + 1;
                        end
                        if(dec) begin
                            if(mm == 4'd1) mm <= 4'd12;
                            else mm <= mm - 1;
                        end
                        // Sau khi đổi tháng, cập nhật lại maxd và chỉnh ngày nếu cần
                        tmp2 = yyyy;
                        while (tmp2 >= 100) tmp2 = tmp2 - 100;
                        rem100 = tmp2;
                        tmp2 = yyyy;
                        while (tmp2 >= 400) tmp2 = tmp2 - 400;
                        rem400 = tmp2;
                        if ((yyyy[1:0] == 2'b00) && (rem100 != 7'd0)) leap = 1'b1;
                        else if (rem400 == 0) leap = 1'b1;
                        else leap = 1'b0;

                        case(mm)
                            4'd1,4'd3,4'd5,4'd7,4'd8,4'd10,4'd12: maxd = 5'd31;
                            4'd4,4'd6,4'd9,4'd11: maxd = 5'd30;
                            4'd2: maxd = leap ? 5'd29 : 5'd28;
                            default: maxd = 5'd31;
                        endcase
                        if(dd > maxd) dd <= maxd;
                    end
                    2'b11: begin // chỉnh năm
                        if(inc) begin
                            if(yyyy == 14'd9999) yyyy <= 14'd0;
                            else yyyy <= yyyy + 1;
                        end
                        if(dec) begin
                            if(yyyy == 14'd0) yyyy <= 14'd9999;
                            else yyyy <= yyyy - 1;
                        end
                        // Sau khi đổi năm, cập nhật lại maxd và chỉnh ngày nếu cần
                        tmp3 = yyyy;
                        while (tmp3 >= 100) tmp3 = tmp3 - 100;
                        rem100 = tmp3;
                        tmp3 = yyyy;
                        while (tmp3 >= 400) tmp3 = tmp3 - 400;
                        rem400 = tmp3;
                        if ((yyyy[1:0] == 2'b00) && (rem100 != 7'd0)) leap = 1'b1;
                        else if (rem400 == 0) leap = 1'b1;
                        else leap = 1'b0;

                        case(mm)
                            4'd1,4'd3,4'd5,4'd7,4'd8,4'd10,4'd12: maxd = 5'd31;
                            4'd4,4'd6,4'd9,4'd11: maxd = 5'd30;
                            4'd2: maxd = leap ? 5'd29 : 5'd28;
                            default: maxd = 5'd31;
                        endcase
                        if(dd > maxd) dd <= maxd;
                    end
                    default: ; // sel==00: không chỉnh gì
                endcase
            end
        end
    end
endmodule