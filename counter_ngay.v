module counter_ngay(
    input  wire       clk, 
    input  wire       rst_n,
    input  wire       inc_auto,
    input  wire       inc_manual, 
    input  wire       dec_manual,
    input  wire [5:0] dim, 
    output reg  [5:0] value,
    output reg        carry_out
);
    reg [5:0] dim_old;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            value<=6'd1; 
            carry_out<=1'b0;
            dim_old <= 6'd0;
        end
        else begin
            carry_out <= 1'b0;
            // Nếu dim thay đổi và value > dim mới thì cập nhật value
            if (dim != dim_old && value > dim) value <= dim;
            dim_old <= dim;
            if (inc_auto) begin
                if (value==dim) begin 
                    value<=6'd1; 
                    carry_out<=1'b1; end
                else value<=value+1'b1;
            end
            // if (value > dim) value <= dim;
            if (inc_manual) value <= (value==dim)?6'd1: value+1'b1;
            if (dec_manual) value <= (value==6'd1) ? dim: value-1'b1;
        end
    end
endmodule
