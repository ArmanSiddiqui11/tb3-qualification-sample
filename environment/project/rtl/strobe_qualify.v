module strobe_qualify (
    input  wire       clk_sys,
    input  wire       rst_n,
    input  wire       strobe_sync_1,
    input  wire [7:0] dwell_n,
    output wire       accept
);
    assign accept = strobe_sync_1;
endmodule
