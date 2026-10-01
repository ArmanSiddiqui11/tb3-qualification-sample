#!/bin/bash
set -euo pipefail
ROOT="${1:-/app}"
OUT="${2:-${ROOT}/output/synth_stat.txt}"
mkdir -p "$(dirname "${OUT}")"

yosys -p "
read_verilog ${ROOT}/project/rtl/async_strobe_sync.v
read_verilog ${ROOT}/project/rtl/strobe_qualify.v
read_verilog ${ROOT}/project/rtl/cfg_regs.v
read_verilog ${ROOT}/project/rtl/pulse_accumulator.v
read_verilog ${ROOT}/project/rtl/gray_cdc_byte.v
read_verilog ${ROOT}/project/rtl/aux_debounce.v
read_verilog ${ROOT}/project/rtl/rst_release.v
read_verilog ${ROOT}/project/rtl/pulse_meter_top.v
hierarchy -check -top pulse_meter_top
synth -top pulse_meter_top
tee -o ${OUT} stat
"
