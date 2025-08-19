module datecounter(
    input clk,
    input rst,
    input dayroll,
    input freeze,
    input inc, dec,
    input [1:0] sel,
    output reg [7:0] dd,
    output reg [7:0] mm,
    output reg [15:0] yyyy
);

    reg [7:0] maxd;
    reg leap;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            dd <= 8'h01;
            mm <= 8'h01;
            yyyy <= 16'h2024;
        end else begin
            // Tính năm nhuận và số ngày tối đa của tháng hiện tại
            leap = ((yyyy % 4 == 0) && (yyyy % 100 != 0)) || (yyyy % 400 == 0);
            case(mm)
                8'h01,8'h03,8'h05,8'h07,8'h08,8'h10,8'h12: maxd = 8'h31;
                8'h04,8'h06,8'h09,8'h11: maxd = 8'h30;
                8'h02: maxd = leap ? 8'h29 : 8'h28;
                default: maxd = 8'h31;
            endcase

            if(!freeze) begin
                if(dayroll) begin
                    if(dd == maxd) begin
                        dd <= 8'h01;
                        if(mm == 8'h12) begin
                            mm <= 8'h01;
                            if(yyyy == 16'h9999) yyyy <= 16'h0000;
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
                            if(dd == maxd) dd <= 8'h01;
                            else dd <= dd + 1;
                        end
                        if(dec) begin
                            if(dd == 8'h01) dd <= maxd;
                            else dd <= dd - 1;
                        end
                    end
                    2'b10: begin // chỉnh tháng
                        if(inc) begin
                            if(mm == 8'h12) mm <= 8'h01;
                            else mm <= mm + 1;
                        end
                        if(dec) begin
                            if(mm == 8'h01) mm <= 8'h12;
                            else mm <= mm - 1;
                        end
                        // Sau khi đổi tháng, cập nhật lại maxd và chỉnh ngày nếu cần
                        leap = ((yyyy % 4 == 0) && (yyyy % 100 != 0)) || (yyyy % 400 == 0);
                        case(mm)
                            8'h01,8'h03,8'h05,8'h07,8'h08,8'h10,8'h12: maxd = 8'h31;
                            8'h04,8'h06,8'h09,8'h11: maxd = 8'h30;
                            8'h02: maxd = leap ? 8'h29 : 8'h28;
                            default: maxd = 8'h31;
                        endcase
                        if(dd > maxd) dd <= maxd;
                    end
                    2'b11: begin // chỉnh năm
                        if(inc) begin
                            if(yyyy == 16'h9999) yyyy <= 16'h0000;
                            else yyyy <= yyyy + 1;
                        end
                        if(dec) begin
                            if(yyyy == 16'h0000) yyyy <= 16'h9999;
                            else yyyy <= yyyy - 1;
                        end
                        // Sau khi đổi năm, cập nhật lại maxd và chỉnh ngày nếu cần
                        leap = ((yyyy % 4 == 0) && (yyyy % 100 != 0)) || (yyyy % 400 == 0);
                        case(mm)
                            8'h01,8'h03,8'h05,8'h07,8'h08,8'h10,8'h12: maxd = 8'h31;
                            8'h04,8'h06,8'h09,8'h11: maxd = 8'h30;
                            8'h02: maxd = leap ? 8'h29 : 8'h28;
                            default: maxd = 8'h31;
                        endcase
                        if(dd > maxd) dd <= maxd;
                    end
                    default: ; // sel==00: không chỉnh gì
                endcase
            end
        end
    end
endmodule