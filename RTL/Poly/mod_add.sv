`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Input: A, B (30-bit)
// Output: C (30-bit)
// 
// 1. A + B
// 2. if (A+B) >= Q, then C = (A+B) - Q
//////////////////////////////////////////////////////////////////////////////////
`include "global_params.vh"

module mod_add(
    input  logic [`DATA_WIDTH-1:0] A,
    input  logic [`DATA_WIDTH-1:0] B,
    output logic [`DATA_WIDTH-1:0] C
);

logic [`DATA_WIDTH:0] temp_sum;
assign temp_sum = A + B;

always_comb begin
    if (temp_sum >= `Q) begin
        C = temp_sum - `Q;
    end
    else begin
        C = temp_sum;
    end
end

endmodule
