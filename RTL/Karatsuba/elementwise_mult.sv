// pointwise_multiply.sv
// Implementation of pointwise multiplication at evaluation points
// Optimized for specific bit widths: ACC_WIDTH=45, MULT_WIDTH=90

`timescale 1ns / 1ps
`include "global_params.vh"
`include "matrix_coefficients.vh"

module elementwise_mult (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic [`ACC_WIDTH-1:0] a_eval[0:`EVAL_ROWS-1], // Evaluation of a(x)
    input  logic [`ACC_WIDTH-1:0] b_eval[0:`EVAL_ROWS-1], // Evaluation of b(x)
    output logic [`ACC_WIDTH-1:0] c_eval[0:`EVAL_ROWS-1]  // Element-wise multiplication result
);

    // Internal signals (used for pipeline stages)
    logic [`ACC_WIDTH-1:0] a_reg[0:`EVAL_ROWS-1];
    logic [`ACC_WIDTH-1:0] b_reg[0:`EVAL_ROWS-1];

    logic [`MULT_WIDTH-1:0] prod[0:`EVAL_ROWS-1];

    // -----------------------------------------------------------------------
    // Stage 1: Input handling
    // -----------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<`EVAL_ROWS; i++) begin
                a_reg[i] <= '0;
                b_reg[i] <= '0;
            end
        end
        else begin
            for (int i=0; i<`EVAL_ROWS; i++) begin
                a_reg[i] <= a_eval[i];
                b_reg[i] <= b_eval[i];
            end
        end
    end

    // -----------------------------------------------------------------------
    // Stage 2: Element-wise multiplication
    // -----------------------------------------------------------------------
    always_comb begin
        for (int i=0; i<`EVAL_ROWS; i++) begin
            prod[i] = a_reg[i] * b_reg[i];
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<`EVAL_ROWS; i++) begin
                c_eval[i] <= '0;
            end
        end
        else begin
            for (int i=0; i<`EVAL_ROWS; i++) begin
                c_eval[i] <= prod[i];
            end
        end
    end

endmodule