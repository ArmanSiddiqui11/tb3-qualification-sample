module rst_release (
    input  wire clk_sys,
    input  wire rst_n,
    output wire rst_sync_0,
    output wire rst_sync_1,
    output wire rst_sync_2
);
    assign rst_sync_0 = rst_n;
    assign rst_sync_1 = rst_n;
    assign rst_sync_2 = rst_n;
endmodule
