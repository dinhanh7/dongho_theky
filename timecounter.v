module timecounter(
    input clk,
    input rst,
    input tick1Hz, // xung 1Hz để đếm thời gian
    input freeze,  // 1: vào chế độ chỉnh sửa
    input inc, dec, // tăng/giảm trường đang chọn
    input [1:0] sel, // chọn trường chỉnh: 00: không chỉnh, 01: ss, 10: mm, 11: hh
    output reg [5:0] ss,
    output reg [5:0] mm,
    output reg [4:0] hh,
    output reg dayroll
);

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            ss <= 6'd0;
            mm <= 6'd0;
            hh <= 5'd0;
            dayroll <= 0;
        end else begin
            dayroll <= 0;
            if(!freeze) begin
                // Đếm thời gian bình thường
                if(tick1Hz) begin
                    if(ss == 6'd59) begin
                        ss <= 6'd0;
                        if(mm == 6'd59) begin
                            mm <= 6'd0;
                            if(hh == 5'd23) begin
                                hh <= 5'd0;
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
                            if(ss == 6'd59) ss <= 6'd0;
                            else ss <= ss + 1;
                        end
                        if(dec) begin
                            if(ss == 6'd0) ss <= 6'd59;
                            else ss <= ss - 1;
                        end
                    end
                    2'b10: begin // chỉnh phút
                        if(inc) begin
                            if(mm == 6'd59) mm <= 6'd0;
                            else mm <= mm + 1;
                        end
                        if(dec) begin
                            if(mm == 6'd0) mm <= 6'd59;
                            else mm <= mm - 1;
                        end
                    end
                    2'b11: begin // chỉnh giờ
                        if(inc) begin
                            if(hh == 5'd23) hh <= 5'd0;
                            else hh <= hh + 1;
                        end
                        if(dec) begin
                            if(hh == 5'd0) hh <= 5'd23;
                            else hh <= hh - 1;
                        end
                    end
                    default: ; // sel==00: không chỉnh gì
                endcase
            end
        end
    end
endmodule