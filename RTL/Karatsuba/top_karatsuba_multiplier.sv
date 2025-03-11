// karatsuba_multiplier.sv
// Karatsuba polynomial multiplier implementation

`timescale 1ns / 1ps
`include "global_params.vh"
`include "matrix_coefficients.vh"

module top_karatsuba_multiplier (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic [`DATA_WIDTH-1:0] a[`N-1:0], // Coefficients of the polynomial a(x)
    input  logic [`DATA_WIDTH-1:0] b[`N-1:0], // Coefficients of the polynomial b(x)
    output logic [`DATA_WIDTH-1:0] c[`N-1:0]  // Coefficients of the polynomial c(x)
);

    // Internal signals (used for pipeline stages)
    logic [`ACC_WIDTH-1:0]  a_eval[`EVAL_ROWS-1:0];
    logic [`ACC_WIDTH-1:0]  b_eval[`EVAL_ROWS-1:0];
    logic [`MULT_WIDTH-1:0] c_eval[`EVAL_ROWS-1:0];

    // -----------------------------------------------------------------------
    // Stage 1: Evaluation of a(x) and b(x)
    // -----------------------------------------------------------------------
    evaluation eval_a_b (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .a_eval(a_eval),
        .b_eval(b_eval)
    );

    // -----------------------------------------------------------------------
    // Stage 2: Element-wise multiplication
    // -----------------------------------------------------------------------
    elementwise_mult elem_mult (
        .clk(clk),
        .rst_n(rst_n),
        .a_eval(a_eval),
        .b_eval(b_eval),
        .c_eval(c_eval)
    );

    // -----------------------------------------------------------------------
    // Stage 3: Interpolation
    // -----------------------------------------------------------------------
    interpolation interp (
        .clk(clk),
        .rst_n(rst_n),
        .c_eval(c_eval),
        .c(c)
    );

endmodule