`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Cooley-Tukey FFT algorithm for 16-point NTT
// 
// Q = 998244353, PSI_16 = 452798380
// 
// Butterfly stage 0
// {0,8}      PSI_16 ^ 8  % Q        8 = intReverse(1,4)
// {1,9}      PSI_16 ^ 8  % Q
// {2,10}     PSI_16 ^ 8  % Q
// {3,11}     PSI_16 ^ 8  % Q
// {4,12}     PSI_16 ^ 8  % Q
// {5,13}     PSI_16 ^ 8  % Q
// {6,14}     PSI_16 ^ 8  % Q
// {7,15}     PSI_16 ^ 8  % Q
//
// Butterfly stage 1
// {0,4}      PSI_16 ^ 4  % Q        4 = intReverse(2,4)
// {1,5}      PSI_16 ^ 4  % Q
// {2,6}      PSI_16 ^ 4  % Q
// {3,7}      PSI_16 ^ 4  % Q
// {8,12}     PSI_16 ^ 12 % Q       12 = intReverse(3,4)
// {9,13}     PSI_16 ^ 12 % Q
// {10,14}    PSI_16 ^ 12 % Q
// {11,15}    PSI_16 ^ 12 % Q
//
// Butterfly stage 2
// {0,2}      PSI_16 ^ 2  % Q        2 = intReverse(4,4)
// {1,3}      PSI_16 ^ 2  % Q
// {4,6}      PSI_16 ^ 10 % Q       10 = intReverse(5,4)
// {5,7}      PSI_16 ^ 10 % Q
// {8,10}     PSI_16 ^ 6  % Q        6 = intReverse(6,4)
// {9,11}     PSI_16 ^ 6  % Q
// {12,14}    PSI_16 ^ 14 % Q       14 = intReverse(7,4)
// {13,15}    PSI_16 ^ 14 % Q
// 
// Butterfly stage 3
// {0,1}      PSI_16 ^ 1  % Q        1 = intReverse(8,4)
// {2,3}      PSI_16 ^ 9  % Q        9 = intReverse(9,4)
// {4,5}      PSI_16 ^ 5  % Q        5 = intReverse(10,4)
// {6,7}      PSI_16 ^ 13 % Q       13 = intReverse(11,4)
// {8,9}      PSI_16 ^ 3  % Q        3 = intReverse(12,4)
// {10,11}    PSI_16 ^ 11 % Q       11 = intReverse(13,4)
// {12,13}    PSI_16 ^ 7  % Q        7 = intReverse(14,4)
// {14,15}    PSI_16 ^ 15 % Q       15 = intReverse(15,4)
//
//////////////////////////////////////////////////////////////////////////////////
`include "global_params.vh"

module CT_BU_array(
    input  logic  clk,
    input  logic  rst_n,

    input  logic [`DATA_WIDTH-1:0]  din[0:15],
    output logic [`DATA_WIDTH-1:0]  dout[0:15]
);

// ----------------------------------------------------------------
// Internal signals
// ----------------------------------------------------------------
logic [`DATA_WIDTH-1:0] stage0_out[0:15];
logic [`DATA_WIDTH-1:0] stage1_out[0:15];
logic [`DATA_WIDTH-1:0] stage2_out[0:15];

logic [`DATA_WIDTH-1:0] PSI_16_1;
logic [`DATA_WIDTH-1:0] PSI_16_2;
logic [`DATA_WIDTH-1:0] PSI_16_3;
logic [`DATA_WIDTH-1:0] PSI_16_4;
logic [`DATA_WIDTH-1:0] PSI_16_5;
logic [`DATA_WIDTH-1:0] PSI_16_6;
logic [`DATA_WIDTH-1:0] PSI_16_7;
logic [`DATA_WIDTH-1:0] PSI_16_8;
logic [`DATA_WIDTH-1:0] PSI_16_9;
logic [`DATA_WIDTH-1:0] PSI_16_10;
logic [`DATA_WIDTH-1:0] PSI_16_11;
logic [`DATA_WIDTH-1:0] PSI_16_12;
logic [`DATA_WIDTH-1:0] PSI_16_13;
logic [`DATA_WIDTH-1:0] PSI_16_14;
logic [`DATA_WIDTH-1:0] PSI_16_15;

// ----------------------------------------------------------------
// Twiddle factors generation
// ----------------------------------------------------------------
initial begin
    PSI_16_8 = 911660635;

    PSI_16_4 = 372528824;       PSI_16_12 = 488723995;

    PSI_16_2 = 929031873;       PSI_16_10 = 373294451;
    PSI_16_6 = 628914303;       PSI_16_14 = 661054123;

    PSI_16_1 = 452798380;       PSI_16_9  = 617152567;
    PSI_16_5 = 170256584;       PSI_16_13 = 645684063;
    PSI_16_3 = 666194801;       PSI_16_11 = 543653592;
    PSI_16_7 = 863921598;       PSI_16_15 = 910687289;
end

// ----------------------------------------------------------------
// Stage 0: {0.8} {1,9} {2,10} {3,11} {4,12} {5,13} {6,14} {7,15}
// ----------------------------------------------------------------
genvar i_stage0;
generate 
    for (i_stage0 = 0; i_stage0 < 8; i_stage0 = i_stage0 + 1) begin: stage0
        ct_butterfly_unit u0_ct_butterfly_unit(
            .clk(clk),
            .rst_n(rst_n),

            .din_0(din[i_stage0]),
            .din_1(din[i_stage0 + 8]),
            .w(PSI_16_8),
            .dout_0(stage0_out[i_stage0]),
            .dout_1(stage0_out[i_stage0 + 8])
        );
    end
endgenerate

// ----------------------------------------------------------------
// Stage 1: {0,4} {1,5} {2,6} {3,7} {8,12} {9,13} {10,14} {11,15}
// ----------------------------------------------------------------
ct_butterfly_unit u10_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[0]),
    .din_1(stage0_out[4]),
    .w(PSI_16_4),
    .dout_0(stage1_out[0]),
    .dout_1(stage1_out[4])
);
ct_butterfly_unit u11_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[1]),
    .din_1(stage0_out[5]),
    .w(PSI_16_4),
    .dout_0(stage1_out[1]),
    .dout_1(stage1_out[5])
);
ct_butterfly_unit u12_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[2]),
    .din_1(stage0_out[6]),
    .w(PSI_16_4),
    .dout_0(stage1_out[2]),
    .dout_1(stage1_out[6])
);
ct_butterfly_unit u13_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[3]),
    .din_1(stage0_out[7]),
    .w(PSI_16_4),
    .dout_0(stage1_out[3]),
    .dout_1(stage1_out[7])
);

ct_butterfly_unit u14_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[8]),
    .din_1(stage0_out[12]),
    .w(PSI_16_12),
    .dout_0(stage1_out[8]),
    .dout_1(stage1_out[12])
);
ct_butterfly_unit u15_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[9]),
    .din_1(stage0_out[13]),
    .w(PSI_16_12),
    .dout_0(stage1_out[9]),
    .dout_1(stage1_out[13])
);
ct_butterfly_unit u16_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[10]),
    .din_1(stage0_out[14]),
    .w(PSI_16_12),
    .dout_0(stage1_out[10]),
    .dout_1(stage1_out[14])
);
ct_butterfly_unit u17_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[11]),
    .din_1(stage0_out[15]),
    .w(PSI_16_12),
    .dout_0(stage1_out[11]),
    .dout_1(stage1_out[15])
);

// ----------------------------------------------------------------
// Stage 2: {0,2} {1,3} {4,6} {5,7} {8,10} {9,11} {12,14} {13,15}
// ----------------------------------------------------------------
ct_butterfly_unit u20_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[0]),
    .din_1(stage1_out[2]),
    .w(PSI_16_2),
    .dout_0(stage2_out[0]),
    .dout_1(stage2_out[2])
);
ct_butterfly_unit u21_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[1]),
    .din_1(stage1_out[3]),
    .w(PSI_16_2),
    .dout_0(stage2_out[1]),
    .dout_1(stage2_out[3])
);

ct_butterfly_unit u22_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[4]),
    .din_1(stage1_out[6]),
    .w(PSI_16_10),
    .dout_0(stage2_out[4]),
    .dout_1(stage2_out[6])
);
ct_butterfly_unit u23_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[5]),
    .din_1(stage1_out[7]),
    .w(PSI_16_10),
    .dout_0(stage2_out[5]),
    .dout_1(stage2_out[7])
);

ct_butterfly_unit u24_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[8]),
    .din_1(stage1_out[10]),
    .w(PSI_16_6),
    .dout_0(stage2_out[8]),
    .dout_1(stage2_out[10])
);
ct_butterfly_unit u25_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[9]),
    .din_1(stage1_out[11]),
    .w(PSI_16_6),
    .dout_0(stage2_out[9]),
    .dout_1(stage2_out[11])
);

ct_butterfly_unit u26_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[12]),
    .din_1(stage1_out[14]),
    .w(PSI_16_14),
    .dout_0(stage2_out[12]),
    .dout_1(stage2_out[14])
);
ct_butterfly_unit u27_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[13]),
    .din_1(stage1_out[15]),
    .w(PSI_16_14),
    .dout_0(stage2_out[13]),
    .dout_1(stage2_out[15])
);

// ----------------------------------------------------------------
// Stage 3: {0,1} {2,3} {4,5} {6,7} {8,9} {10,11} {12,13} {14,15}
// ----------------------------------------------------------------
ct_butterfly_unit u30_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage2_out[0]),
    .din_1(stage2_out[1]),
    .w(PSI_16_1),
    .dout_0(dout[0]),
    .dout_1(dout[1])
);
ct_butterfly_unit u31_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage2_out[2]),
    .din_1(stage2_out[3]),
    .w(PSI_16_9),
    .dout_0(dout[2]),
    .dout_1(dout[3])
);
ct_butterfly_unit u32_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage2_out[4]),
    .din_1(stage2_out[5]),
    .w(PSI_16_5),
    .dout_0(dout[4]),
    .dout_1(dout[5])
);
ct_butterfly_unit u33_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage2_out[6]),
    .din_1(stage2_out[7]),
    .w(PSI_16_13),
    .dout_0(dout[6]),
    .dout_1(dout[7])
);
ct_butterfly_unit u34_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage2_out[8]),
    .din_1(stage2_out[9]),
    .w(PSI_16_3),
    .dout_0(dout[8]),
    .dout_1(dout[9])
);
ct_butterfly_unit u35_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage2_out[10]),
    .din_1(stage2_out[11]),
    .w(PSI_16_11),
    .dout_0(dout[10]),
    .dout_1(dout[11])
);
ct_butterfly_unit u36_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage2_out[12]),
    .din_1(stage2_out[13]),
    .w(PSI_16_7),
    .dout_0(dout[12]),
    .dout_1(dout[13])
);
ct_butterfly_unit u37_ct_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage2_out[14]),
    .din_1(stage2_out[15]),
    .w(PSI_16_15),
    .dout_0(dout[14]),
    .dout_1(dout[15])
);


endmodule