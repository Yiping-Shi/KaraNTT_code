`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Gentlemen-Sande FFT algorithm for 16-point INTT
// A0 -\--|+|--------- B0
//       \/
//       /\
// A1 -/--|-|----|x|-- B1
// 
// Q = 998244353, PSI_16_INV = 87557064
// 
//
//////////////////////////////////////////////////////////////////////////////////
`include "global_params.vh"

module gs_butterfly_unit(
    input  logic  clk,
    input  logic  rst_n,

    input  logic [`DATA_WIDTH-1:0]  din_0,
    input  logic [`DATA_WIDTH-1:0]  din_1,
    input  logic [`DATA_WIDTH-1:0]  w,
    output logic [`DATA_WIDTH-1:0]  dout_0,
    output logic [`DATA_WIDTH-1:0]  dout_1
);

// Internal signal
logic [`DATA_WIDTH-1:0] temp_0;
logic [`DATA_WIDTH-1:0] temp_1;

logic [`MULT_WIDTH-1:0] temp_0_c;
logic [`MULT_WIDTH-1:0] temp_0_2c;
logic [`MULT_WIDTH-1:0] temp_0_3c;

// Delay the temp_0 by 4 cycles
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        temp_0_c  <= '0;
        temp_0_2c <= '0;
        temp_0_3c <= '0;
        dout_0    <= '0;
    end 
    else begin
        temp_0_c  <= temp_0;
        temp_0_2c <= temp_0_c;
        temp_0_3c <= temp_0_2c;
        dout_0    <= temp_0_3c;
    end
end

mod_add u0_mod_add(
    .A(din_0),
    .B(din_1),
    .C(temp_0)
);

mod_sub u0_mod_sub(
    .A(din_0),
    .B(din_1),
    .C(temp_1)
);

mod_mult_barrett u0_mod_mult_barrett(
    .clk(clk),
    .rst_n(rst_n),
    .A(temp_1),
    .B(w),
    .C(dout_1)
);

endmodule