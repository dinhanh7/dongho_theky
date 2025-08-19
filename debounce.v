module debounce(
    input clk,
    input btn,
    output reg pulse
);
    reg [19:0] cnt;
    reg btn0, btn1, btn2; //3 tang thanh ghi de dong bo
    wire btn_sync;

    //dong bo hoa voi nut clock
    always @(posedge clk) begin
        btn0 <= btn;
        btn1 <= btn0;
        btn2 <= btn1;
    end
    assign btn_sync = btn2;

    always @(posedge clk) begin
        if(btn_sync == 0)
            cnt <= 0;
        else if(cnt < 20'd999_999) //day chi la 1 so rat lon
            cnt <= cnt+1;
        else
            cnt <= cnt;
    end

    reg btn_state;
    always @(posedge clk) begin
        if(cnt == 20'd999_999)
            btn_state <= 1'b1;
        else
            btn_state <= 1'b0;
    end
    reg btn_state_d;
    always @(posedge clk) btn_state_d <= btn_state;
    always @(posedge clk) pulse <= btn_state & ~btn_state_d;

endmodule
