module gray_cdc_byte (
    input  wire       clk_src,
    input  wire       clk_dst,
    input  wire       rst_n,
    input  wire [7:0] din_bin,
    output reg  [7:0] dout_bin
);
    always @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n)
            dout_bin <= 8'd0;
        else
            dout_bin <= din_bin;
    end
endmodule
