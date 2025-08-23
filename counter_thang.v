module counter_thang(
    input  wire       clk, 
    input  wire       rst_n,
    input  wire       inc_auto,
    input  wire       inc_manual, 
    input  wire       dec_manual,
    input leap,
    output reg  [3:0] value,
    output reg        carry_out,
    output reg [5:0] dim
);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            value<=4'd1; 
            carry_out<=1'b0; end
        else begin
            carry_out <= 1'b0;
            if (inc_auto) begin
                if (value==4'd12) begin 
                    value<=4'd1; 
                    carry_out<=1'b1; end
                else value<=value+1'b1;
            end
            if (inc_manual) value <= (value==4'd12)?4'd1: value+1'b1;
            if (dec_manual) value <= (value==4'd1) ?4'd12: value-1'b1;
        end
        case(value)
                4'd1,4'd3,4'd5,4'd7,4'd8,4'd10,4'd12: dim = 6'd31;
                4'd4,4'd6,4'd9,4'd11: dim = 6'd30;
                4'd2: dim = leap ? 6'd29 : 6'd28;
                default: dim = 6'd31;
            endcase
    end
endmodule
