module counter_nam(
    input  wire       clk, 
    input  wire       rst_n,
    input  wire       inc_auto,
    input  wire       inc_manual, 
    input  wire       dec_manual,
    output reg  [13:0] value,
    output wire leap
);
    reg [1:0] y_mod4;
    reg [6:0] y_mod100;
    reg [8:0] y_mod400;
    assign leap = ((y_mod4 == 2'd0) && (y_mod100 != 7'd0)) || (y_mod400 == 9'd0);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            value<=14'd2024; 
            y_mod4   <= 2'd0;   // 2024 mod 4 = 0
            y_mod100 <= 7'd24;  // 2024 mod 100 = 24
            y_mod400 <= 9'd24;
            end
        else begin
            if (inc_auto) begin
                if (value==14'd9999) begin 
                    value<=14'd0;
                    y_mod4   <= 2'd0;
                    y_mod100 <= 7'd0;
                    y_mod400 <= 9'd0;  end
                else begin 
                value<=value+1'b1;
                y_mod4   <= (y_mod4 == 2'd3)   ? 2'd0   : y_mod4  + 1'b1;
                y_mod100 <= (y_mod100 == 7'd99)  ? 7'd0   : y_mod100 + 1'b1;
                y_mod400 <= (y_mod400 == 9'd399) ? 9'd0   : y_mod400 + 1'b1;
                end
            end
            if (inc_manual) begin
                if(value == 14'd9999) begin
                    value <= 14'd0;
                    y_mod4   <= 2'd0;
                    y_mod100 <= 7'd0;
                    y_mod400 <= 9'd0;
                end else begin
                    value <= value + 1;
                    y_mod4   <= (y_mod4 == 2'd3)   ? 2'd0   : y_mod4  + 1'b1;
                    y_mod100 <= (y_mod100 == 7'd99)  ? 7'd0   : y_mod100 + 1'b1;
                    y_mod400 <= (y_mod400 == 9'd399) ? 9'd0   : y_mod400 + 1'b1;
                end                
                end
            if (dec_manual) begin
                if(value == 14'd0) begin
                    value <= 14'd9999;
                    y_mod4   <= 2'd3;
                    y_mod100 <= 7'd99;
                    y_mod400 <= 9'd399;
                end else begin
                    value <= value - 1;
                    y_mod4   <= (y_mod4 == 2'd0)   ? 2'd3    : y_mod4  - 1'b1;
                    y_mod100 <= (y_mod100 == 7'd0)   ? 7'd99   : y_mod100-1'b1;
                    y_mod400 <= (y_mod400 == 9'd0)   ? 9'd399  : y_mod400-1'b1;
                end
            end
        end
    end
endmodule
