module timecounter(
    input clk,
    input rst,
    input tick1Hz, // xung 1Hz để đếm thời gian
    input freeze,  // 1: vào chế độ chỉnh sửa
    input inc, dec, // tăng/giảm trường đang chọn
    input [1:0] sel, // chọn trường chỉnh: 00: không chỉnh, 01: ss, 10: mm, 11: hh
    output reg [7:0] ss,
    output reg [7:0] mm,
    output reg [7:0] hh,
    output reg dayroll
);

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            ss <= 8'h00;
            mm <= 8'h00;
            hh <= 8'h00;
            dayroll <= 0;
        end else begin
            dayroll <= 0;
            if(!freeze) begin
                // Đếm thời gian bình thường
                if(tick1Hz) begin
                    if(ss == 8'h59) begin
                        ss <= 8'h00;
                        if(mm == 8'h59) begin
                            mm <= 8'h00;
                            if(hh == 8'h23) begin
                                hh <= 8'h00;
                                dayroll <= 1;
                            end else begin
                                hh <= hh + 1;
                            end
                        end else begin
                            mm <= mm + 1;
                        end
                    end else begin
                        ss <= ss + 1;
                    end
                end
            end else begin
                // Chỉ cho phép chỉnh sửa khi freeze=1 và sel!=00
                case(sel)
                    2'b01: begin // chỉnh giây
                        if(inc) begin
                            if(ss == 8'h59) ss <= 8'h00;
                            else ss <= ss + 1;
                        end
                        if(dec) begin
                            if(ss == 8'h00) ss <= 8'h59;
                            else ss <= ss - 1;
                        end
                    end
                    2'b10: begin // chỉnh phút
                        if(inc) begin
                            if(mm == 8'h59) mm <= 8'h00;
                            else mm <= mm + 1;
                        end
                        if(dec) begin
                            if(mm == 8'h00) mm <= 8'h59;
                            else mm <= mm - 1;
                        end
                    end
                    2'b11: begin // chỉnh giờ
                        if(inc) begin
                            if(hh == 8'h23) hh <= 8'h00;
                            else hh <= hh + 1;
                        end
                        if(dec) begin
                            if(hh == 8'h00) hh <= 8'h23;
                            else hh <= hh - 1;
                        end
                    end
                    default: ; // sel==00: không chỉnh gì
                endcase
            end
        end
    end
endmodule