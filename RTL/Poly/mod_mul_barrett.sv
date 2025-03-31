`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Input: A, B (30-bit)
// Output: C (30-bit)
// 
//////////////////////////////////////////////////////////////////////////////////
`include "global_params.vh"

module mod_mult_barrett(
    input  logic clk,
    input  logic rst_n,

    input  logic [`DATA_WIDTH-1:0] A,
    input  logic [`DATA_WIDTH-1:0] B,
    output logic [`DATA_WIDTH-1:0] C
);

// Stage 0: Input
logic [`DATA_WIDTH-1:0] s1_A;
logic [`DATA_WIDTH-1:0] s1_B;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        s1_A <= '0;
        s1_B <= '0;
    end 
    else begin
        s1_A <= A;
        s1_B <= B;
    end
end

// Stage 1: Multiply P = A * B
logic [`DATA_WIDTH*2-1:0] s2_P;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        s2_P <= '0;
    end 
    else begin
        s2_P <= s1_A * s1_B;
    end
end

// Stage 2: Q_approx = ((P>>DATA_WIDTH) * U)>>DATA_WIDTH
logic [`DATA_WIDTH*2-1:0] s3_P;
logic [`DATA_WIDTH*2-1:0] s3_Q_approx;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        s3_P        <= '0;
        s3_Q_approx <= '0;
    end 
    else begin
        s3_P        <= s2_P;
        s3_Q_approx <= ((s2_P>>`DATA_WIDTH) * `U)>>`DATA_WIDTH;
    end
end

// Stage 3: P - (Q_approx * Q)
logic [`DATA_WIDTH*2-1:0] s4_C;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        s4_C <= '0;
    end
    else begin
        // 1) R = P - (Q_approx * Q)
        logic [2*`DATA_WIDTH-1:0] q_mult = s3_Q_approx * `Q;
        logic [2*`DATA_WIDTH-1:0] R      = s3_P - q_mult;

        // 2) 如果 R >= 2Q, R -= 2Q; else if R >= Q, R-= Q
        //    这里要用大位宽比较(>30bit). 
        logic [2*`DATA_WIDTH-1:0] twoQ = (`Q << 1);
        if (R >= twoQ) begin
            s4_C <= (R - twoQ);
        end
        else if (R >= `Q) begin
            s4_C <= (R - `Q);
        end
        else begin
            s4_C <= R;
        end
    end
end

// Output
assign C = s4_C[`DATA_WIDTH-1:0];

endmodule
