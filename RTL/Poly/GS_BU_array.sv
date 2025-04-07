`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////
//
// Q = 998244353, PSI_16_INV = 87557064
//
// Butterfly stage 0
// {0,1}    PSI_16_INV ^ 1  % Q        1 = intReverse(8,4)
// {2,3}    PSI_16_INV ^ 9  % Q        9 = intReverse(9,4)
// {4,5}    PSI_16_INV ^ 5  % Q        5 = intReverse(10,4)
// {6,7}    PSI_16_INV ^ 13 % Q       13 = intReverse(11,4)
// {8,9}    PSI_16_INV ^ 3  % Q        3 = intReverse(12,4)
// {10,11}  PSI_16_INV ^ 11 % Q       11 = intReverse(13,4)
// {12,13}  PSI_16_INV ^ 7  % Q        7 = intReverse(14,4)
// {14,15}  PSI_16_INV ^ 15 % Q       15 = intReverse(15,4)
//
// Butterfly stage 1
// {0,2}    PSI_16_INV ^ 2  % Q        2 = intReverse(4,4)
// {1,3}    PSI_16_INV ^ 2  % Q
// {4,6}    PSI_16_INV ^ 10 % Q       10 = intReverse(5,4)
// {5,7}    PSI_16_INV ^ 10 % Q
// {8,10}   PSI_16_INV ^ 6  % Q        6 = intReverse(6,4)
// {9,11}   PSI_16_INV ^ 6  % Q
// {12,14}  PSI_16_INV ^ 14 % Q       14 = intReverse(7,4)
// {13,15}  PSI_16_INV ^ 14 % Q
//
// Butterfly stage 2
// {0,4}    PSI_16_INV ^ 4  % Q        4 = intReverse(2,4)
// {1,5}    PSI_16_INV ^ 4  % Q
// {2,6}    PSI_16_INV ^ 4  % Q
// {3,7}    PSI_16_INV ^ 4  % Q
// {8,12}   PSI_16_INV ^ 12 % Q       12 = intReverse(3,4)
// {9,13}   PSI_16_INV ^ 12 % Q
// {10,14}  PSI_16_INV ^ 12 % Q
// {11,15}  PSI_16_INV ^ 12 % Q
//
// Butterfly stage 3
// {0,8}    PSI_16_INV ^ 8  % Q        8 = intReverse(1,4)
// {1,9}    PSI_16_INV ^ 8  % Q
// {2,10}   PSI_16_INV ^ 8  % Q
// {3,11}   PSI_16_INV ^ 8  % Q
// {4,12}   PSI_16_INV ^ 8  % Q
// {5,13}   PSI_16_INV ^ 8  % Q
// {6,14}   PSI_16_INV ^ 8  % Q
// {7,15}   PSI_16_INV ^ 8  % Q
//
//////////////////////////////////////////////////////////////////////////////////////////
`include "global_params.vh"

module GS_BU_array(
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
logic [`DATA_WIDTH-1:0] stage3_out[0:15];

logic [`DATA_WIDTH-1:0] PSI_16_INV_1;
logic [`DATA_WIDTH-1:0] PSI_16_INV_2;  
logic [`DATA_WIDTH-1:0] PSI_16_INV_3;
logic [`DATA_WIDTH-1:0] PSI_16_INV_4;
logic [`DATA_WIDTH-1:0] PSI_16_INV_5;
logic [`DATA_WIDTH-1:0] PSI_16_INV_6;
logic [`DATA_WIDTH-1:0] PSI_16_INV_7;
logic [`DATA_WIDTH-1:0] PSI_16_INV_8;
logic [`DATA_WIDTH-1:0] PSI_16_INV_9;
logic [`DATA_WIDTH-1:0] PSI_16_INV_10;
logic [`DATA_WIDTH-1:0] PSI_16_INV_11;
logic [`DATA_WIDTH-1:0] PSI_16_INV_12;
logic [`DATA_WIDTH-1:0] PSI_16_INV_13;
logic [`DATA_WIDTH-1:0] PSI_16_INV_14;
logic [`DATA_WIDTH-1:0] PSI_16_INV_15;

// ----------------------------------------------------------------
// Twiddle factors generation
// ----------------------------------------------------------------
initial begin
    PSI_16_INV_8 = 87557064;

    PSI_16_INV_4 = 509520358;         PSI_16_INV_12 = 625715529;

    PSI_16_INV_2 = 337190230;         PSI_16_INV_10 = 624949902;
    PSI_16_INV_6 = 69212480;          PSI_16_INV_14 = 545445973;

    PSI_16_INV_1 = 87557064;          PSI_16_INV_9 = 134322755;
    PSI_16_INV_5 = 454590761;         PSI_16_INV_13 = 332049552;    
    PSI_16_INV_3 = 352560290;         PSI_16_INV_11 = 827987769;
    PSI_16_INV_7 = 381091786;         PSI_16_INV_15 = 545445973;
end

// ----------------------------------------------------------------
// Stage 0: {0,1} {2,3} {4,5} {6,7} {8,9} {10,11} {12,13} {14,15}
// ----------------------------------------------------------------
gs_butterfly_unit u00_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(din[0]),
    .din_1(din[1]),
    .w(PSI_16_INV_1),
    .dout_0(stage0_out[0]),
    .dout_1(stage0_out[1])
);
gs_butterfly_unit u01_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(din[2]),
    .din_1(din[3]),
    .w(PSI_16_INV_9),
    .dout_0(stage0_out[2]),
    .dout_1(stage0_out[3])
);
gs_butterfly_unit u02_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(din[4]),
    .din_1(din[5]),
    .w(PSI_16_INV_5),
    .dout_0(stage0_out[4]),
    .dout_1(stage0_out[5])
);
gs_butterfly_unit u03_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(din[6]),
    .din_1(din[7]),
    .w(PSI_16_INV_13),
    .dout_0(stage0_out[6]),
    .dout_1(stage0_out[7])
);
gs_butterfly_unit u04_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(din[8]),
    .din_1(din[9]),
    .w(PSI_16_INV_3),
    .dout_0(stage0_out[8]),
    .dout_1(stage0_out[9])
);
gs_butterfly_unit u05_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(din[10]),
    .din_1(din[11]),
    .w(PSI_16_INV_11),
    .dout_0(stage0_out[10]),
    .dout_1(stage0_out[11])
);
gs_butterfly_unit u06_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(din[12]),
    .din_1(din[13]),
    .w(PSI_16_INV_7),
    .dout_0(stage0_out[12]),
    .dout_1(stage0_out[13])
);
gs_butterfly_unit u07_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(din[14]),
    .din_1(din[15]),
    .w(PSI_16_INV_15),
    .dout_0(stage0_out[14]),
    .dout_1(stage0_out[15])
);

// ----------------------------------------------------------------
// Stage 1: {0,2} {1,3} {4,6} {5,7} {8,10} {9,11} {12,14} {13,15}
// ----------------------------------------------------------------
gs_butterfly_unit u10_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[0]),
    .din_1(stage0_out[2]),
    .w(PSI_16_INV_2),
    .dout_0(stage1_out[0]),
    .dout_1(stage1_out[2])
);
gs_butterfly_unit u11_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[1]),
    .din_1(stage0_out[3]),
    .w(PSI_16_INV_2),
    .dout_0(stage1_out[1]),
    .dout_1(stage1_out[3])
);

gs_butterfly_unit u12_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[4]),
    .din_1(stage0_out[6]),
    .w(PSI_16_INV_10),
    .dout_0(stage1_out[4]),
    .dout_1(stage1_out[6])
);
gs_butterfly_unit u13_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[5]),
    .din_1(stage0_out[7]),
    .w(PSI_16_INV_10),
    .dout_0(stage1_out[5]),
    .dout_1(stage1_out[7])
);

gs_butterfly_unit u14_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[8]),
    .din_1(stage0_out[10]),
    .w(PSI_16_INV_6),
    .dout_0(stage1_out[8]),
    .dout_1(stage1_out[10])
);
gs_butterfly_unit u15_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[9]),
    .din_1(stage0_out[11]),
    .w(PSI_16_INV_6),
    .dout_0(stage1_out[9]),
    .dout_1(stage1_out[11])
);

gs_butterfly_unit u16_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[12]),
    .din_1(stage0_out[14]),
    .w(PSI_16_INV_14),
    .dout_0(stage1_out[12]),
    .dout_1(stage1_out[14])
);
gs_butterfly_unit u17_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage0_out[13]),
    .din_1(stage0_out[15]),
    .w(PSI_16_INV_14),
    .dout_0(stage1_out[13]),
    .dout_1(stage1_out[15])
);

// ----------------------------------------------------------------
// Stage 2: {0,4} {1,5} {2,6} {3,7} {8,12} {9,13} {10,14} {11,15}
// ----------------------------------------------------------------
gs_butterfly_unit u20_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[0]),
    .din_1(stage1_out[4]),
    .w(PSI_16_INV_4),
    .dout_0(stage2_out[0]),
    .dout_1(stage2_out[4])
);
gs_butterfly_unit u21_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[1]),
    .din_1(stage1_out[5]),
    .w(PSI_16_INV_4),
    .dout_0(stage2_out[1]),
    .dout_1(stage2_out[5])
);
gs_butterfly_unit u22_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[2]),
    .din_1(stage1_out[6]),
    .w(PSI_16_INV_4),
    .dout_0(stage2_out[2]),
    .dout_1(stage2_out[6])
);
gs_butterfly_unit u23_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[3]),
    .din_1(stage1_out[7]),
    .w(PSI_16_INV_4),
    .dout_0(stage2_out[3]),
    .dout_1(stage2_out[7])
);

gs_butterfly_unit u24_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[8]),
    .din_1(stage1_out[12]),
    .w(PSI_16_INV_12),
    .dout_0(stage2_out[8]),
    .dout_1(stage2_out[12])
);
gs_butterfly_unit u25_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[9]),
    .din_1(stage1_out[13]),
    .w(PSI_16_INV_12),
    .dout_0(stage2_out[9]),
    .dout_1(stage2_out[13])
);
gs_butterfly_unit u26_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[10]),
    .din_1(stage1_out[14]),
    .w(PSI_16_INV_12),
    .dout_0(stage2_out[10]),
    .dout_1(stage2_out[14])
);
gs_butterfly_unit u27_gs_butterfly_unit(
    .clk(clk),
    .rst_n(rst_n),

    .din_0(stage1_out[11]),
    .din_1(stage1_out[15]),
    .w(PSI_16_INV_12),
    .dout_0(stage2_out[11]),
    .dout_1(stage2_out[15])
);

// ----------------------------------------------------------------
// Stage 0: {0.8} {1,9} {2,10} {3,11} {4,12} {5,13} {6,14} {7,15}
// ----------------------------------------------------------------
genvar i_stage0;
generate 
    for (i_stage0 = 0; i_stage0 < 8; i_stage0 = i_stage0 + 1) begin: stage0
        gs_butterfly_unit u0_gs_butterfly_unit(
            .clk(clk),
            .rst_n(rst_n),

            .din_0(stage2_out[i_stage0]),
            .din_1(stage2_out[i_stage0 + 8]),
            .w(PSI_16_INV_8),
            .dout_0(stage3_out[i_stage0]),
            .dout_1(stage3_out[i_stage0 + 8])
        );
    end
endgenerate

// ----------------------------------------------------------------
// Output normalization
// ----------------------------------------------------------------
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin: output_normalization
        mod_mult_barrett u0_mod_mult_barrett(
            .clk(clk),
            .rst_n(rst_n),
            .A(stage3_out[i]),
            .B(`N_16_INV),
            .C(dout[i])
        );
    end
endgenerate

endmodule