// interpolation_module.sv
// Polynomial interpolation and final modular reduction
// Transforms point-value representation back to coefficient form

`timescale 1ns / 1ps
`include "global_params.vh"

module interpolation (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic [`MULT_WIDTH-1:0] c_eval[0:`EVAL_ROWS-1], // Element-wise multiplication result
    output logic [`MULT_WIDTH-1:0] c[0:`N-1]               // Coefficients of the polynomial c(x)
);

    // Internal signals (used for pipeline stages)
    logic [`MULT_WIDTH-1:0] c_reg_1_0[0:4];
    logic [`MULT_WIDTH-1:0] c_reg_1_1[0:4];
    logic [`MULT_WIDTH-1:0] c_reg_1_2[0:3];
    logic [`MULT_WIDTH-1:0] c_reg_1_3[0:5];
    logic [`MULT_WIDTH-1:0] c_reg_1_4[0:2];
    logic [`MULT_WIDTH-1:0] c_reg_1_5[0:3];
    logic [`MULT_WIDTH-1:0] c_reg_1_6[0:3];
    logic [`MULT_WIDTH-1:0] c_reg_1_7[0:6];
    logic [`MULT_WIDTH-1:0] c_reg_1_8[0:3];
    logic [`MULT_WIDTH-1:0] c_reg_1_9[0:3];
    logic [`MULT_WIDTH-1:0] c_reg_1_10[0:2];
    logic [`MULT_WIDTH-1:0] c_reg_1_11[0:5];
    logic [`MULT_WIDTH-1:0] c_reg_1_12[0:3];
    logic [`MULT_WIDTH-1:0] c_reg_1_13[0:4];
    logic [`MULT_WIDTH-1:0] c_reg_1_14[0:4];
    logic [`MULT_WIDTH-1:0] c_reg_1_15[0:9];

    // -----------------------------------------------------------------------
    // Stage 1
    // -----------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<5; i++) begin
                c_reg_1_0[i]  <= '0;
            end
            for (int i=0; i<5; i++) begin
                c_reg_1_1[i]  <= '0;
            end
            for (int i=0; i<4; i++) begin
                c_reg_1_2[i]  <= '0;
            end
            for (int i=0; i<6; i++) begin
                c_reg_1_3[i]  <= '0;
            end
            for (int i=0; i<3; i++) begin
                c_reg_1_4[i]  <= '0;
            end
            for (int i=0; i<4; i++) begin
                c_reg_1_5[i]  <= '0;
            end
            for (int i=0; i<4; i++) begin
                c_reg_1_6[i]  <= '0;
            end
            for (int i=0; i<7; i++) begin
                c_reg_1_7[i]  <= '0;
            end
            for (int i=0; i<4; i++) begin
                c_reg_1_8[i]  <= '0;
            end
            for (int i=0; i<4; i++) begin
                c_reg_1_9[i]  <= '0;
            end
            for (int i=0; i<3; i++) begin
                c_reg_1_10[i] <= '0;
            end
            for (int i=0; i<6; i++) begin
                c_reg_1_11[i] <= '0;
            end
            for (int i=0; i<4; i++) begin
                c_reg_1_12[i] <= '0;
            end
            for (int i=0; i<5; i++) begin
                c_reg_1_13[i] <= '0;
            end
            for (int i=0; i<5; i++) begin
                c_reg_1_14[i] <= '0;
            end
            for (int i=0; i<10; i++) begin
                c_reg_1_15[i] <= '0;
            end
        end
        else begin
            c_reg_1_0[0]  <=   c_eval[0]  + c_eval[2]  - c_eval[5]  - c_eval[6]  + c_eval[8]  - c_eval[11] + c_eval[14] + c_eval[15];
            c_reg_1_0[1]  <= - c_eval[17] + c_eval[18] + c_eval[20] - c_eval[23] - c_eval[24] + c_eval[26] - c_eval[29] + c_eval[32];
            c_reg_1_0[2]  <=   c_eval[33] - c_eval[35] + c_eval[38] - c_eval[41] - c_eval[42] + c_eval[44] - c_eval[45] - c_eval[47];
            c_reg_1_0[3]  <=   c_eval[50] + c_eval[51] - c_eval[53] - c_eval[54] + c_eval[56] - c_eval[59] - c_eval[60] + c_eval[62];
            c_reg_1_0[4]  <= - c_eval[65] + c_eval[68] + c_eval[69] - c_eval[71] + c_eval[72] + c_eval[74] - c_eval[77] - c_eval[78] + c_eval[80];

            c_reg_1_1[0]  <= - c_eval[0]  + c_eval[1]  - c_eval[2]  + c_eval[6]  - c_eval[7]  + c_eval[8]  - c_eval[15] + c_eval[16];
            c_reg_1_1[1]  <= - c_eval[17] - c_eval[18] + c_eval[19] - c_eval[20] + c_eval[24] - c_eval[25] + c_eval[26] - c_eval[33];
            c_reg_1_1[2]  <=   c_eval[34] - c_eval[35] + c_eval[42] - c_eval[43] + c_eval[44] + c_eval[45] - c_eval[46] + c_eval[47];
            c_reg_1_1[3]  <= - c_eval[51] + c_eval[52] - c_eval[53] + c_eval[54] - c_eval[55] + c_eval[56] + c_eval[60] - c_eval[61] + c_eval[62];
            c_reg_1_1[4]  <= - c_eval[69] + c_eval[70] - c_eval[71] - c_eval[72] + c_eval[73] - c_eval[74] + c_eval[78] - c_eval[79] + c_eval[80];

            c_reg_1_2[0]  <= - c_eval[0]  + c_eval[2]  + c_eval[3]  - c_eval[6]  - c_eval[8]  + c_eval[17] - c_eval[18] + c_eval[20];
            c_reg_1_2[1]  <=   c_eval[21] - c_eval[24] - c_eval[26] + c_eval[35] - c_eval[44] + c_eval[45] - c_eval[47] - c_eval[48];
            c_reg_1_2[2]  <=   c_eval[51] + c_eval[53] + c_eval[54] - c_eval[56] - c_eval[57] + c_eval[60] - c_eval[62] + c_eval[71];
            c_reg_1_2[3]  <= - c_eval[72] + c_eval[74] + c_eval[75] - c_eval[78] - c_eval[80];

            c_reg_1_3[0]  <=   c_eval[0]  - c_eval[1]  + c_eval[2]  - c_eval[3]  + c_eval[4]  - c_eval[5]  + c_eval[6]  - c_eval[7];
            c_reg_1_3[1]  <=   c_eval[8]  + c_eval[18] - c_eval[19] + c_eval[20] - c_eval[21] + c_eval[22] - c_eval[23] + c_eval[24];
            c_reg_1_3[2]  <= - c_eval[25] + c_eval[26] - c_eval[45] + c_eval[46] - c_eval[47] + c_eval[48] - c_eval[49] + c_eval[50];
            c_reg_1_3[3]  <= - c_eval[51] + c_eval[52] - c_eval[53] - c_eval[54] + c_eval[55] - c_eval[56] + c_eval[57] - c_eval[58];
            c_reg_1_3[4]  <=   c_eval[59] - c_eval[60] + c_eval[61] - c_eval[62] + c_eval[72] - c_eval[73] + c_eval[74] - c_eval[75];
            c_reg_1_3[5]  <=   c_eval[76] - c_eval[77] + c_eval[78] - c_eval[79] + c_eval[80];

            c_reg_1_4[0]  <= - c_eval[0]  - c_eval[2]  + c_eval[5]  + c_eval[6]  - c_eval[8]  + c_eval[9]  - c_eval[18] - c_eval[20];
            c_reg_1_4[1]  <=   c_eval[23] + c_eval[24] - c_eval[26] + c_eval[47] - c_eval[50] - c_eval[51] + c_eval[53] + c_eval[54] + c_eval[56];
            c_reg_1_4[2]  <= - c_eval[59] - c_eval[60] + c_eval[62] - c_eval[63] + c_eval[72] - c_eval[74] + c_eval[77] + c_eval[78] - c_eval[80];

            c_reg_1_5[0]  <=   c_eval[0]  - c_eval[1]  + c_eval[2]  - c_eval[6]  + c_eval[7]  - c_eval[8]  - c_eval[9]  + c_eval[10];
            c_reg_1_5[1]  <= - c_eval[11] + c_eval[18] - c_eval[19] + c_eval[20] - c_eval[24] + c_eval[25] - c_eval[26] + c_eval[51];
            c_reg_1_5[2]  <= - c_eval[52] + c_eval[53] - c_eval[54] + c_eval[55] - c_eval[56] + c_eval[60] - c_eval[61] + c_eval[62];  
            c_reg_1_5[3]  <=   c_eval[63] - c_eval[64] + c_eval[65] - c_eval[72] + c_eval[73] - c_eval[74] - c_eval[78] + c_eval[79] - c_eval[80];

            c_reg_1_6[0]  <=   c_eval[0]  - c_eval[2]  - c_eval[3]  + c_eval[6]  + c_eval[8]  - c_eval[9]  + c_eval[11] + c_eval[12];
            c_reg_1_6[1]  <= - c_eval[15] + c_eval[18] - c_eval[20] - c_eval[21] + c_eval[24] + c_eval[26] - c_eval[53] - c_eval[54];
            c_reg_1_6[2]  <=   c_eval[56] + c_eval[57] - c_eval[60] - c_eval[62] + c_eval[63] - c_eval[65] - c_eval[66] + c_eval[69];
            c_reg_1_6[3]  <= - c_eval[72] + c_eval[74] + c_eval[75] - c_eval[78] + c_eval[80];

            c_reg_1_7[0]  <= - c_eval[0]  + c_eval[1]  - c_eval[2]  + c_eval[3]  - c_eval[4]  + c_eval[5]  - c_eval[6]  + c_eval[7];
            c_reg_1_7[1]  <= - c_eval[8]  + c_eval[9]  - c_eval[10] + c_eval[11] - c_eval[12] + c_eval[13] - c_eval[14] + c_eval[15];
            c_reg_1_7[2]  <= - c_eval[16] + c_eval[17] - c_eval[18] + c_eval[19] - c_eval[20] + c_eval[21] - c_eval[22] + c_eval[23];
            c_reg_1_7[3]  <= - c_eval[24] + c_eval[25] - c_eval[26] + c_eval[54] - c_eval[55] + c_eval[56] - c_eval[57] + c_eval[58];
            c_reg_1_7[4]  <= - c_eval[59] + c_eval[60] - c_eval[61] + c_eval[62] - c_eval[63] + c_eval[64] - c_eval[65] + c_eval[66];
            c_reg_1_7[5]  <= - c_eval[67] + c_eval[68] - c_eval[69] + c_eval[70] - c_eval[71] + c_eval[72] - c_eval[73] + c_eval[74];
            c_reg_1_7[6]  <= - c_eval[75] + c_eval[76] - c_eval[77] + c_eval[78] - c_eval[79] + c_eval[80];

            c_reg_1_8[0]  <= - c_eval[0]  + c_eval[2]  - c_eval[5]  - c_eval[6]  + c_eval[8]  - c_eval[11] + c_eval[14] + c_eval[15];
            c_reg_1_8[1]  <= - c_eval[17] + c_eval[18] + c_eval[20] - c_eval[23] - c_eval[24] + c_eval[26] + c_eval[27] - c_eval[54];
            c_reg_1_8[2]  <= - c_eval[56] + c_eval[59] + c_eval[60] - c_eval[62] + c_eval[65] - c_eval[68] - c_eval[69] + c_eval[71];
            c_reg_1_8[3]  <= - c_eval[72] - c_eval[74] + c_eval[77] + c_eval[78] - c_eval[80];

            c_reg_1_9[0]  <=   c_eval[0]  - c_eval[1]  + c_eval[2]  + c_eval[6]  - c_eval[7]  + c_eval[8]  - c_eval[15] + c_eval[16];
            c_reg_1_9[1]  <= - c_eval[17] - c_eval[18] + c_eval[19] - c_eval[20] + c_eval[24] - c_eval[25] + c_eval[26] - c_eval[27];
            c_reg_1_9[2]  <=   c_eval[28] - c_eval[29] + c_eval[54] - c_eval[55] + c_eval[56] - c_eval[60] + c_eval[61] - c_eval[62];
            c_reg_1_9[3]  <=   c_eval[69] - c_eval[70] + c_eval[71] + c_eval[72] - c_eval[73] + c_eval[74] - c_eval[78] + c_eval[79] - c_eval[80];

            c_reg_1_10[0] <=   c_eval[0]  - c_eval[2]  - c_eval[3]  + c_eval[6]  - c_eval[8]  + c_eval[17] - c_eval[18] + c_eval[20];
            c_reg_1_10[1] <=   c_eval[21] - c_eval[24] - c_eval[26] - c_eval[27] + c_eval[29] + c_eval[30] - c_eval[33] + c_eval[54] - c_eval[56];
            c_reg_1_10[2] <= - c_eval[57] + c_eval[60] + c_eval[62] - c_eval[71] + c_eval[72] - c_eval[74] - c_eval[75] + c_eval[78] + c_eval[80];

            c_reg_1_11[0] <= - c_eval[0]  + c_eval[1]  - c_eval[2]  + c_eval[3]  - c_eval[4]  + c_eval[5]  - c_eval[6]  + c_eval[7];
            c_reg_1_11[1] <= - c_eval[8]  + c_eval[18] - c_eval[19] + c_eval[20] - c_eval[21] + c_eval[22] - c_eval[23] + c_eval[24];
            c_reg_1_11[2] <= - c_eval[25] + c_eval[26] + c_eval[27] - c_eval[28] + c_eval[29] - c_eval[30] + c_eval[31] - c_eval[32];
            c_reg_1_11[3] <=   c_eval[33] - c_eval[34] + c_eval[35] - c_eval[54] + c_eval[55] - c_eval[56] + c_eval[57] - c_eval[58];
            c_reg_1_11[4] <=   c_eval[59] - c_eval[60] + c_eval[61] - c_eval[62] - c_eval[72] + c_eval[73] - c_eval[74] + c_eval[75];
            c_reg_1_11[5] <= - c_eval[76] + c_eval[77] - c_eval[78] + c_eval[79] - c_eval[80];

            c_reg_1_12[0] <=   c_eval[0]  + c_eval[2]  - c_eval[5]  - c_eval[6]  + c_eval[8]  - c_eval[9]  + c_eval[18] - c_eval[20];
            c_reg_1_12[1] <=   c_eval[23] + c_eval[24] - c_eval[26] - c_eval[27] - c_eval[29] + c_eval[32] + c_eval[33] - c_eval[35];
            c_reg_1_12[2] <=   c_eval[36] - c_eval[45] + c_eval[54] + c_eval[56] - c_eval[59] - c_eval[60] + c_eval[62] - c_eval[63];
            c_reg_1_12[3] <=   c_eval[72] + c_eval[74] - c_eval[77] - c_eval[78] + c_eval[80];

            c_reg_1_13[0] <= - c_eval[0]  + c_eval[1]  - c_eval[2]  + c_eval[6]  - c_eval[7]  + c_eval[8]  + c_eval[9]  - c_eval[10];
            c_reg_1_13[1] <=   c_eval[11] - c_eval[18] + c_eval[19] - c_eval[20] - c_eval[24] + c_eval[25] - c_eval[26] + c_eval[27];
            c_reg_1_13[2] <= - c_eval[28] + c_eval[29] - c_eval[33] + c_eval[34] - c_eval[35] - c_eval[36] + c_eval[37] - c_eval[38];
            c_reg_1_13[3] <=   c_eval[45] - c_eval[46] + c_eval[47] - c_eval[54] + c_eval[55] - c_eval[56] + c_eval[60] - c_eval[61] + c_eval[62];
            c_reg_1_13[4] <=   c_eval[63] - c_eval[64] + c_eval[65] - c_eval[72] + c_eval[73] - c_eval[74] + c_eval[78] - c_eval[79] + c_eval[80];

            c_reg_1_14[0] <= - c_eval[0]  + c_eval[2]  + c_eval[3]  - c_eval[6]  - c_eval[8]  + c_eval[9]  - c_eval[11] - c_eval[12];
            c_reg_1_14[1] <=   c_eval[15] - c_eval[18] + c_eval[20] + c_eval[21] - c_eval[24] + c_eval[26] + c_eval[27] - c_eval[29];
            c_reg_1_14[2] <= - c_eval[30] + c_eval[33] + c_eval[35] - c_eval[36] + c_eval[38] + c_eval[39] - c_eval[42] + c_eval[45];
            c_reg_1_14[3] <= - c_eval[47] - c_eval[48] + c_eval[51] - c_eval[54] + c_eval[56] + c_eval[57] - c_eval[60] - c_eval[62];
            c_reg_1_14[4] <=   c_eval[63] - c_eval[65] - c_eval[66] + c_eval[69] - c_eval[72] + c_eval[74] + c_eval[75] - c_eval[78] - c_eval[80];

            c_reg_1_15[0] <=   c_eval[0]  - c_eval[1]  + c_eval[2]  - c_eval[3]  + c_eval[4]  - c_eval[5]  + c_eval[6]  - c_eval[7];
            c_reg_1_15[1] <=   c_eval[8]  - c_eval[9]  + c_eval[10] - c_eval[11] + c_eval[12] - c_eval[13] + c_eval[14] - c_eval[15];
            c_reg_1_15[2] <=   c_eval[16] - c_eval[17] + c_eval[18] - c_eval[19] + c_eval[20] - c_eval[21] + c_eval[22] - c_eval[23];
            c_reg_1_15[3] <=   c_eval[24] - c_eval[25] + c_eval[26] - c_eval[27] + c_eval[28] - c_eval[29] + c_eval[30] - c_eval[31];
            c_reg_1_15[4] <=   c_eval[32] - c_eval[33] + c_eval[34] - c_eval[35] + c_eval[36] - c_eval[37] + c_eval[38] - c_eval[39];
            c_reg_1_15[5] <=   c_eval[40] - c_eval[41] + c_eval[42] - c_eval[43] + c_eval[44] - c_eval[45] + c_eval[46] - c_eval[47];
            c_reg_1_15[6] <=   c_eval[48] - c_eval[49] + c_eval[50] - c_eval[51] + c_eval[52] - c_eval[53] + c_eval[54] - c_eval[55];
            c_reg_1_15[7] <=   c_eval[56] - c_eval[57] + c_eval[58] - c_eval[59] + c_eval[60] - c_eval[61] + c_eval[62] - c_eval[63];
            c_reg_1_15[8] <=   c_eval[64] - c_eval[65] + c_eval[66] - c_eval[67] + c_eval[68] - c_eval[69] + c_eval[70] - c_eval[71];
            c_reg_1_15[9] <=   c_eval[72] - c_eval[73] + c_eval[74] - c_eval[75] + c_eval[76] - c_eval[77] + c_eval[78] - c_eval[79] + c_eval[80];
        end
    end

    // -----------------------------------------------------------------------
    // Stage 2
    // -----------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<`N; i++) begin
                c[i] <= '0;
            end
        end
        else begin
            c[0]  <= c_reg_1_0[0]  + c_reg_1_0[1]  + c_reg_1_0[2]  + c_reg_1_0[3]  + c_reg_1_0[4];
            c[1]  <= c_reg_1_1[0]  + c_reg_1_1[1]  + c_reg_1_1[2]  + c_reg_1_1[3]  + c_reg_1_1[4];
            c[2]  <= c_reg_1_2[0]  + c_reg_1_2[1]  + c_reg_1_2[2]  + c_reg_1_2[3];
            c[3]  <= c_reg_1_3[0]  + c_reg_1_3[1]  + c_reg_1_3[2]  + c_reg_1_3[3]  + c_reg_1_3[4]  + c_reg_1_3[5];
            c[4]  <= c_reg_1_4[0]  + c_reg_1_4[1]  + c_reg_1_4[2]; 
            c[5]  <= c_reg_1_5[0]  + c_reg_1_5[1]  + c_reg_1_5[2]  + c_reg_1_5[3];
            c[6]  <= c_reg_1_6[0]  + c_reg_1_6[1]  + c_reg_1_6[2]  + c_reg_1_6[3];
            c[7]  <= c_reg_1_7[0]  + c_reg_1_7[1]  + c_reg_1_7[2]  + c_reg_1_7[3]  + c_reg_1_7[4]  + c_reg_1_7[5]  + c_reg_1_7[6];
            c[8]  <= c_reg_1_8[0]  + c_reg_1_8[1]  + c_reg_1_8[2]  + c_reg_1_8[3];
            c[9]  <= c_reg_1_9[0]  + c_reg_1_9[1]  + c_reg_1_9[2]  + c_reg_1_9[3];
            c[10] <= c_reg_1_10[0] + c_reg_1_10[1] + c_reg_1_10[2];
            c[11] <= c_reg_1_11[0] + c_reg_1_11[1] + c_reg_1_11[2] + c_reg_1_11[3] + c_reg_1_11[4] + c_reg_1_11[5];
            c[12] <= c_reg_1_12[0] + c_reg_1_12[1] + c_reg_1_12[2] + c_reg_1_12[3];
            c[13] <= c_reg_1_13[0] + c_reg_1_13[1] + c_reg_1_13[2] + c_reg_1_13[3] + c_reg_1_13[4];
            c[14] <= c_reg_1_14[0] + c_reg_1_14[1] + c_reg_1_14[2] + c_reg_1_14[3] + c_reg_1_14[4];
            c[15] <= c_reg_1_15[0] + c_reg_1_15[1] + c_reg_1_15[2] + c_reg_1_15[3] + c_reg_1_15[4] + c_reg_1_15[5] + c_reg_1_15[6] + c_reg_1_15[7] + c_reg_1_15[8] + c_reg_1_15[9];
        end
    end

endmodule