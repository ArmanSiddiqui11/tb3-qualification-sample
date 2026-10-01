module cfg_regs (
    input  wire       clk_sys,
    input  wire       rst_n,
    input  wire       cfg_wr,
    input  wire [1:0] cfg_addr,
    input  wire [7:0] cfg_wdata,
    output wire [7:0] config_div,
    output wire [7:0] dwell_n
);
    assign config_div = cfg_wr ? cfg_wdata : 8'd0;
    assign dwell_n    = 8'd0;
endmodule
