`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Input: A, B (30-bit)
// Output: C (30-bit)
// 
// 1. if (A>=B), then C = A-B
// 2. if (A< B), then C = B-A
//////////////////////////////////////////////////////////////////////////////////
`include "global_params.vh"

module mod_sub(
    input  logic [`DATA_WIDTH-1:0] A,
    input  logic [`DATA_WIDTH-1:0] B,
    output logic [`DATA_WIDTH-1:0] C
);

always_comb begin
    if (A >= B) begin
        C = A - B;
    end
    else begin
        C = `Q + A - B;
    end
end

endmodule
