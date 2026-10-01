#!/bin/bash
set -euo pipefail
ROOT="${1:-/app}"
VEC="${2:-${ROOT}/project/sim/vectors_primary.csv}"
OUT="${3:-${ROOT}/output/sim_trace_primary.csv}"
mkdir -p "$(dirname "${OUT}")"

cat > /tmp/tb_pulse_meter.v <<EOF
\`timescale 1ns/1ps
module tb_pulse_meter;
    reg        clk_sys;
    reg        clk_stat;
    reg        rst_n;
    reg        sample_strobe_async;
    reg  [7:0] sample_in;
    reg        cfg_wr;
    reg  [1:0] cfg_addr;
    reg  [7:0] cfg_wdata;
    wire       pulse_out;
    wire [7:0] acc_value;
    wire [7:0] stat_count;
    wire       fault_filt;
    wire       rst_sys_n;

    integer fd_in, fd_out, rc, cycle, rst_i, strobe_i, sample_i, wr_i, addr_i, wdata_i;
    integer dummy;
    reg [8*256-1:0] line;

    pulse_meter_top dut (
        .clk_sys             (clk_sys),
        .clk_stat            (clk_stat),
        .rst_n               (rst_n),
        .sample_strobe_async (sample_strobe_async),
        .sample_in           (sample_in),
        .cfg_wr              (cfg_wr),
        .cfg_addr            (cfg_addr),
        .cfg_wdata           (cfg_wdata),
        .pulse_out           (pulse_out),
        .acc_value           (acc_value),
        .stat_count          (stat_count),
        .fault_async         (1'b0),
        .fault_filt          (fault_filt),
        .rst_sys_n           (rst_sys_n)
    );

    initial begin
        clk_sys = 0;
        forever #5 clk_sys = ~clk_sys;
    end

    initial begin
        clk_stat = 0;
        #2;
        forever #7.5 clk_stat = ~clk_stat;
    end

    initial begin
        rst_n = 0;
        sample_strobe_async = 0;
        sample_in = 0;
        cfg_wr = 0;
        cfg_addr = 0;
        cfg_wdata = 0;
        fd_in = \$fopen("${VEC}", "r");
        if (fd_in == 0) begin
            \$display("failed to open vectors ${VEC}");
            \$finish;
        end
        fd_out = \$fopen("${OUT}", "w");
        dummy = \$fgets(line, fd_in);
        \$fwrite(fd_out, "cycle,rst_n,strobe,sample,cfg_wr,cfg_addr,cfg_wdata,pulse,acc,stat_count\\n");
        while (!\$feof(fd_in)) begin
            rc = \$fscanf(fd_in, "%d,%d,%d,%d,%d,%d,%d\\n", cycle, rst_i, strobe_i, sample_i, wr_i, addr_i, wdata_i);
            if (rc != 7) begin
                dummy = \$fgets(line, fd_in);
            end else begin
                @(negedge clk_sys);
                rst_n = rst_i[0];
                sample_strobe_async = strobe_i[0];
                sample_in = sample_i[7:0];
                cfg_wr = wr_i[0];
                cfg_addr = addr_i[1:0];
                cfg_wdata = wdata_i[7:0];
                @(posedge clk_sys);
                #1;
                \$fwrite(fd_out, "%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d\\n",
                    cycle, rst_n, sample_strobe_async, sample_in, cfg_wr, cfg_addr, cfg_wdata,
                    pulse_out, acc_value, stat_count);
            end
        end
        \$fclose(fd_in);
        \$fclose(fd_out);
        \$finish;
    end
endmodule
EOF

iverilog -g2012 -o /tmp/pulse_meter.vvp \
  "${ROOT}/project/rtl/async_strobe_sync.v" \
  "${ROOT}/project/rtl/strobe_qualify.v" \
  "${ROOT}/project/rtl/cfg_regs.v" \
  "${ROOT}/project/rtl/pulse_accumulator.v" \
  "${ROOT}/project/rtl/gray_cdc_byte.v" \
  "${ROOT}/project/rtl/aux_debounce.v" \
  "${ROOT}/project/rtl/rst_release.v" \
  "${ROOT}/project/rtl/pulse_meter_top.v" \
  /tmp/tb_pulse_meter.v

vvp /tmp/pulse_meter.vvp
