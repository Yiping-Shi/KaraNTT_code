// barrett_reduce.sv
// Barrett modular reduction module
// Implements a 3-stage pipeline to reduce a large value modulo Q

`timescale 1ns / 1ps
`include "global_params.vh"

module barrett_reduce(
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic [`ACC_WIDTH-1:0]  value_in,  // Large value to reduce
    output logic [`DATA_WIDTH-1:0] result_out // Result = value_in mod Q
);
    // Constants
    localparam logic [`DATA_WIDTH*2-1:0] twoQ = (`Q << 1);

    // Stage 1: Input handling
    logic [`ACC_WIDTH-1:0]    s1_value;
    logic [`DATA_WIDTH*2-1:0] s1_Q_approx;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1_value    <= '0;
            s1_Q_approx <= '0;
        end 
        else begin
            s1_value    <= value_in;          
            // Calculate Q_approx = ⌊(value / 2^DATA_WIDTH) * U / 2^DATA_WIDTH⌋
            s1_Q_approx <= ((value_in>>`DATA_WIDTH) * `U)>>`DATA_WIDTH;
        end
    end

    // Stage 2: Calculate remainder R = value - (Q_approx * Q)
    logic [`DATA_WIDTH*2-1:0] s2_R;
    logic [`DATA_WIDTH*2-1:0] q_mult;

    always_comb begin
        q_mult = s1_Q_approx * `Q;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s2_R     <= '0;
        end
        else begin
            // Calculate R = value - (Q_approx * Q)
            s2_R <= s1_value - q_mult;
        end
    end

    // Stage 3: Final correction
    logic [`DATA_WIDTH-1:0]   s3_result;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s3_result <= '0;
        end
        else begin
            // At most 2 subtractions are needed for correctness
            if (s2_R >= twoQ) begin
                s3_result <= s2_R - twoQ;
            end
            else if (s2_R >= `Q) begin
                s3_result <= s2_R - `Q;
            end
            else begin
                s3_result <= s2_R[`DATA_WIDTH-1:0];
            end
        end
    end

    // Output assignment
    assign result_out = s3_result;

endmodule