module aux_debounce #(
    parameter integer STABLE_N = 5
) (
    input  wire clk_sys,
    input  wire rst_n,
    input  wire fault_async,
    output wire fault_filt
);
    assign fault_filt = fault_async;
endmodule
