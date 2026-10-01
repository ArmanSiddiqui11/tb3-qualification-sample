module async_strobe_sync (
    input  wire clk_sys,
    input  wire rst_n,
    input  wire sample_strobe_async,
    output wire strobe_sync_0,
    output wire strobe_sync_1
);
    reg strobe_sync_0_r;

    always @(posedge clk_sys or negedge rst_n) begin
        if (!rst_n)
            strobe_sync_0_r <= 1'b0;
        else
            strobe_sync_0_r <= sample_strobe_async;
    end

    assign strobe_sync_0 = strobe_sync_0_r;
    assign strobe_sync_1 = strobe_sync_0_r;
endmodule
