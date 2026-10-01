module pulse_meter_top (
    input  wire       clk_sys,
    input  wire       clk_stat,
    input  wire       rst_n,
    input  wire       sample_strobe_async,
    input  wire [7:0] sample_in,
    input  wire       cfg_wr,
    input  wire [1:0] cfg_addr,
    input  wire [7:0] cfg_wdata,
    output wire       pulse_out,
    output wire [7:0] acc_value,
    output wire [7:0] stat_count,
    input  wire       fault_async,
    output wire       fault_filt,
    output wire       rst_sys_n
);
    wire       strobe_sync_0;
    wire       strobe_sync_1;
    wire       accept;
    wire [7:0] config_div;
    wire [7:0] dwell_n;
    wire [6:0] acc_narrow;
    wire [7:0] sample_count;
    wire       rst_sync_0;
    wire       rst_sync_1;

    async_strobe_sync u_cdc_strobe (
        .clk_sys             (clk_sys),
        .rst_n               (rst_n),
        .sample_strobe_async (sample_strobe_async),
        .strobe_sync_0       (strobe_sync_0),
        .strobe_sync_1       (strobe_sync_1)
    );

    strobe_qualify u_qualify (
        .clk_sys       (clk_sys),
        .rst_n         (rst_n),
        .strobe_sync_1 (strobe_sync_1),
        .dwell_n       (dwell_n),
        .accept        (accept)
    );

    cfg_regs u_cfg (
        .clk_sys    (clk_sys),
        .rst_n      (rst_n),
        .cfg_wr     (cfg_wr),
        .cfg_addr   (cfg_addr),
        .cfg_wdata  (cfg_wdata),
        .config_div (config_div),
        .dwell_n    (dwell_n)
    );

    pulse_accumulator u_acc (
        .clk_sys             (clk_sys),
        .rst_n               (rst_n),
        .sample_strobe_async (sample_strobe_async),
        .accept              (accept),
        .sample_in           (sample_in),
        .config_div          (config_div),
        .pulse_out           (pulse_out),
        .acc_value           (acc_narrow),
        .sample_count        (sample_count)
    );

    assign acc_value = {1'b0, acc_narrow};

    gray_cdc_byte u_stat_cdc (
        .clk_src  (clk_sys),
        .clk_dst  (clk_stat),
        .rst_n    (rst_n),
        .din_bin  (sample_count),
        .dout_bin (stat_count)
    );

    aux_debounce u_debounce (
        .clk_sys     (clk_sys),
        .rst_n       (rst_n),
        .fault_async (fault_async),
        .fault_filt  (fault_filt)
    );

    rst_release u_rst_rel (
        .clk_sys    (clk_sys),
        .rst_n      (rst_n),
        .rst_sync_0 (rst_sync_0),
        .rst_sync_1 (rst_sync_1),
        .rst_sync_2 (rst_sys_n)
    );
endmodule
