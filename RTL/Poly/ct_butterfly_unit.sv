`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Cooley-Tukey FFT algorithm for 16-point NTT
// A0 -------\--|+|-- B0
//             \/
//             /\
// A1 --|x|--/--|-|-- B1
// 
// Q = 998244353, PSI_16 = 452798380
// 
//
//////////////////////////////////////////////////////////////////////////////////
`include "global_params.vh"

module ct_butterfly_unit(
    input  logic  clk,
    input  logic  rst_n,

    input  logic [`DATA_WIDTH-1:0]  din_0,
    input  logic [`DATA_WIDTH-1:0]  din_1,
    input  logic [`DATA_WIDTH-1:0]  w,
    output logic [`DATA_WIDTH-1:0]  dout_0,
    output logic [`DATA_WIDTH-1:0]  dout_1
);

// Internal signal
logic [`MULT_WIDTH-1:0] din_0_c;
logic [`MULT_WIDTH-1:0] din_0_2c;
logic [`MULT_WIDTH-1:0] din_0_3c;

logic [`DATA_WIDTH-1:0] temp_0;
logic [`DATA_WIDTH-1:0] temp_1;

// Delay the input din_0 by 4 cycles
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        din_0_c  <= '0;
        din_0_2c <= '0;
        din_0_3c <= '0;
        temp_0   <= '0;
    end 
    else begin
        din_0_c  <= din_0;
        din_0_2c <= din_0_c;
        din_0_3c <= din_0_2c;
        temp_0   <= din_0_3c;
    end
end

mod_mult_barrett u0_mod_mult_barrett(
    .clk(clk),
    .rst_n(rst_n),
    .A(din_1),
    .B(w),
    .C(temp_1)
);

mod_add u0_mod_add(
    .A(din_0),
    .B(temp_1),
    .C(dout_0)
);

mod_sub u0_mod_sub(
    .A(din_0),
    .B(temp_1),
    .C(dout_1)
);

endmodule