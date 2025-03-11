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
    logic [`MULT_WIDTH-1:0] c_reg_1[0:`N-1][0:1];
    logic [`MULT_WIDTH-1:0] c_reg_2[0:`N-1][0:1];
    logic [`MULT_WIDTH-1:0] c_reg_3[0:`N-1][0:1];

    // -----------------------------------------------------------------------
    // Stage 1
    // -----------------------------------------------------------------------
    c_reg_1[0][0]  <=   c_eval[0]  + c_eval[2]  - c_eval[5]  - c_eval[6]  + c_eval[8]  - c_eval[11] + c_eval[14] + c_eval[15];
    c_reg_1[0][1]  <= - c_eval[17] + c_eval[18] + c_eval[20] - c_eval[23] - c_eval[24] + c_eval[26] - c_eval[29] + c_eval[32];
    c_reg_1[0][2]  <=   c_eval[33] - c_eval[35] + c_eval[38] - c_eval[41] - c_eval[42] + c_eval[44] - c_eval[45] - c_eval[47];
    c_reg_1[0][3]  <=   c_eval[50] + c_eval[51] - c_eval[53] - c_eval[54] + c_eval[56] - c_eval[59] - c_eval[60] + c_eval[62];
    c_reg_1[0][4]  <= - c_eval[65] + c_eval[68] + c_eval[69] - c_eval[71] + c_eval[72] + c_eval[74] - c_eval[77] - c_eval[78] + c_eval[80];

    c_reg_1[1][0]  <= - c_eval[0]  + c_eval[1]  - c_eval[2]  + c_eval[6]  - c_eval[7]  + c_eval[8]  - c_eval[15] + c_eval[16];
    c_reg_1[1][1]  <= - c_eval[17] - c_eval[18] + c_eval[19] - c_eval[20] + c_eval[24] - c_eval[25] + c_eval[26] - c_eval[33];
    c_reg_1[1][2]  <=   c_eval[34] - c_eval[35] + c_eval[42] - c_eval[43] + c_eval[44] + c_eval[45] - c_eval[46] + c_eval[47];
    c_reg_1[1][3]  <= - c_eval[51] + c_eval[52] - c_eval[53] + c_eval[54] - c_eval[55] + c_eval[56] + c_eval[60] - c_eval[61] + c_eval[62];
    c_reg_1[1][4]  <= - c_eval[69] + c_eval[70] - c_eval[71] - c_eval[72] + c_eval[73] - c_eval[74] + c_eval[78] - c_eval[79] + c_eval[80];

    c_reg_1[2][0]  <= - c_eval[0]  + c_eval[2]  + c_eval[3]  - c_eval[6]  - c_eval[8]  + c_eval[17] - c_eval[18] + c_eval[20];
    c_reg_1[2][1]  <=   c_eval[21] - c_eval[24] - c_eval[26] + c_eval[35] - c_eval[44] + c_eval[45] - c_eval[47] - c_eval[48];
    c_reg_1[2][2]  <=   c_eval[51] + c_eval[53] + c_eval[54] - c_eval[56] - c_eval[57] + c_eval[60] - c_eval[62] + c_eval[71];
    c_reg_1[2][3]  <= - c_eval[72] + c_eval[74] + c_eval[75] - c_eval[78] - c_eval[80];

    c_reg_1[3][0]  <=   c_eval[0]  - c_eval[1]  + c_eval[2]  - c_eval[3]  + c_eval[4]  - c_eval[5]  + c_eval[6]  - c_eval[7];
    c_reg_1[3][1]  <=   c_eval[8]  + c_eval[18] - c_eval[19] + c_eval[20] - c_eval[21] + c_eval[22] - c_eval[23] + c_eval[24];
    c_reg_1[3][2]  <= - c_eval[25] + c_eval[26] - c_eval[45] + c_eval[46] - c_eval[47] + c_eval[48] - c_eval[49] + c_eval[50];
    c_reg_1[3][3]  <= - c_eval[51] + c_eval[52] - c_eval[53] - c_eval[54] + c_eval[55] - c_eval[56] + c_eval[57] - c_eval[58];
    c_reg_1[3][4]  <=   c_eval[59] - c_eval[60] + c_eval[61] - c_eval[62] + c_eval[72] - c_eval[73] + c_eval[74] - c_eval[75];
    c_reg_1[3][5]  <=   c_eval[76] - c_eval[77] + c_eval[78] - c_eval[79] + c_eval[80];

    c_reg_1[4][0]  <= - c_eval[0]  - c_eval[2]  + c_eval[5]  + c_eval[6]  - c_eval[8]  + c_eval[9]  - c_eval[18] - c_eval[20];
    c_reg_1[4][1]  <=   c_eval[23] + c_eval[24] - c_eval[26] + c_eval[47] - c_eval[50] - c_eval[51] + c_eval[53] + c_eval[54] + c_eval[56];
    c_reg_1[4][2]  <= - c_eval[59] - c_eval[60] + c_eval[62] - c_eval[63] + c_eval[72] - c_eval[74] + c_eval[77] + c_eval[78] - c_eval[80];

    c_reg_1[5][0]  <=   c_eval[0]  - c_eval[1]  + c_eval[2]  - c_eval[6]  + c_eval[7]  - c_eval[8]  - c_eval[9]  + c_eval[10];
    c_reg_1[5][1]  <= - c_eval[11] + c_eval[18] - c_eval[19] + c_eval[20] - c_eval[24] + c_eval[25] - c_eval[26] + c_eval[51];
    c_reg_1[5][2]  <= - c_eval[52] + c_eval[53] - c_eval[54] + c_eval[55] - c_eval[56] + c_eval[60] - c_eval[61] + c_eval[62];  
    c_reg_1[5][3]  <=   c_eval[63] - c_eval[64] + c_eval[65] - c_eval[72] + c_eval[73] - c_eval[74] - c_eval[78] + c_eval[79] - c_eval[80];

    c_reg_1[6][0]  <=   c_eval[0]  - c_eval[2]  - c_eval[3]  + c_eval[6]  + c_eval[8]  - c_eval[9]  + c_eval[11] + c_eval[12];
    c_reg_1[6][1]  <= - c_eval[15] + c_eval[18] - c_eval[20] - c_eval[21] + c_eval[24] + c_eval[26] - c_eval[53] - c_eval[54];
    c_reg_1[6][2]  <=   c_eval[56] + c_eval[57] - c_eval[60] - c_eval[62] + c_eval[63] - c_eval[65] - c_eval[66] + c_eval[69];
    c_reg_1[6][3]  <= - c_eval[72] + c_eval[74] + c_eval[75] - c_eval[78] + c_eval[80];

    c_reg_1[7][0]  <= - c_eval[0]  + c_eval[1]  - c_eval[2]  + c_eval[3]  - c_eval[4]  + c_eval[5]  - c_eval[6]  + c_eval[7];
    c_reg_1[7][1]  <= - c_eval[8]  + c_eval[9]  - c_eval[10] + c_eval[11] - c_eval[12] + c_eval[13] - c_eval[14] + c_eval[15];
    c_reg_1[7][2]  <= - c_eval[16] + c_eval[17] - c_eval[18] + c_eval[19] - c_eval[20] + c_eval[21] - c_eval[22] + c_eval[23];
    c_reg_1[7][3]  <= - c_eval[24] + c_eval[25] - c_eval[26] + c_eval[54] - c_eval[55] + c_eval[56] - c_eval[57] + c_eval[58];
    c_reg_1[7][4]  <= - c_eval[59] + c_eval[60] - c_eval[61] + c_eval[62] - c_eval[63] + c_eval[64] - c_eval[65] + c_eval[66];
    c_reg_1[7][5]  <= - c_eval[67] + c_eval[68] - c_eval[69] + c_eval[70] - c_eval[71] + c_eval[72] - c_eval[73] + c_eval[74];
    c_reg_1[7][6]  <= - c_eval[75] + c_eval[76] - c_eval[77] + c_eval[78] - c_eval[79] + c_eval[80];

    c_reg_1[8][0]  <= - c_eval[0]  + c_eval[2]  - c_eval[5]  - c_eval[6]  + c_eval[8]  - c_eval[11] + c_eval[14] + c_eval[15];
    c_reg_1[8][1]  <= - c_eval[17] + c_eval[18] + c_eval[20] - c_eval[23] - c_eval[24] + c_eval[26] + c_eval[27] - c_eval[54];
    c_reg_1[8][2]  <= - c_eval[56] + c_eval[59] + c_eval[60] - c_eval[62] + c_eval[65] - c_eval[68] - c_eval[69] + c_eval[71];
    c_reg_1[8][3]  <= - c_eval[72] - c_eval[74] + c_eval[77] + c_eval[78] - c_eval[80];

    c_reg_1[9][0]  <=   c_eval[0]  - c_eval[1]  + c_eval[2]  + c_eval[6]  - c_eval[7]  + c_eval[8]  - c_eval[15] + c_eval[16];
    c_reg_1[9][1]  <= - c_eval[17] - c_eval[18] + c_eval[19] - c_eval[20] + c_eval[24] - c_eval[25] + c_eval[26] - c_eval[27];
    c_reg_1[9][2]  <=   c_eval[28] - c_eval[29] + c_eval[54] - c_eval[55] + c_eval[56] - c_eval[60] + c_eval[61] - c_eval[62];
    c_reg_1[9][3]  <=   c_eval[69] - c_eval[70] + c_eval[71] + c_eval[72] - c_eval[73] + c_eval[74] - c_eval[78] + c_eval[79] - c_eval[80];

    c_reg_1[10][0] <=   c_eval[0]  - c_eval[2]  - c_eval[3]  + c_eval[6]  - c_eval[8]  + c_eval[17] - c_eval[18] + c_eval[20];
    c_reg_1[10][1] <=   c_eval[21] - c_eval[24] - c_eval[26] - c_eval[27] + c_eval[29] + c_eval[30] - c_eval[33] + c_eval[54] - c_eval[56];
    c_reg_1[10][2] <= - c_eval[57] + c_eval[60] + c_eval[62] - c_eval[71] + c_eval[72] - c_eval[74] - c_eval[75] + c_eval[78] + c_eval[80];

    c_reg_1[11][0] <= - c_eval[0]  + c_eval[1]  - c_eval[2]  + c_eval[3]  - c_eval[4]  + c_eval[5]  - c_eval[6]  + c_eval[7];
    c_reg_1[11][1] <= - c_eval[8]  + c_eval[18] - c_eval[19] + c_eval[20] - c_eval[21] + c_eval[22] - c_eval[23] + c_eval[24];
    c_reg_1[11][2] <= - c_eval[25] + c_eval[26] + c_eval[27] - c_eval[28] + c_eval[29] - c_eval[30] + c_eval[31] - c_eval[32];
    c_reg_1[11][3] <=   c_eval[33] - c_eval[34] + c_eval[35] - c_eval[54] + c_eval[55] - c_eval[56] + c_eval[57] - c_eval[58];
    c_reg_1[11][4] <=   c_eval[59] - c_eval[60] + c_eval[61] - c_eval[62] - c_eval[72] + c_eval[73] - c_eval[74] + c_eval[75];
    c_reg_1[11][5] <= - c_eval[76] + c_eval[77] - c_eval[78] + c_eval[79] - c_eval[80];
    
    c_reg_1[12][0] <=   c_eval[0]  + c_eval[2]  - c_eval[5]  - c_eval[6]  + c_eval[8]  - c_eval[9]  + c_eval[18] - c_eval[20];
    c_reg_1[12][1] <=   c_eval[23] + c_eval[24] - c_eval[26] - c_eval[27] - c_eval[29] + c_eval[32] + c_eval[33] - c_eval[35];
    c_reg_1[12][2] <=   c_eval[36] - c_eval[45] + c_eval[54] + c_eval[56] - c_eval[59] - c_eval[60] + c_eval[62] - c_eval[63];
    c_reg_1[12][3] <=   c_eval[72] + c_eval[74] - c_eval[77] - c_eval[78] + c_eval[80];

    c_reg_1[13][0] <= - c_eval[0]  + c_eval[1]  - c_eval[2]  + c_eval[6]  - c_eval[7]  + c_eval[8]  + c_eval[9]  - c_eval[10];
    c_reg_1[13][1] <=   c_eval[11] - c_eval[18] + c_eval[19] - c_eval[20] - c_eval[24] + c_eval[25] - c_eval[26] + c_eval[27];
    c_reg_1[13][2] <= - c_eval[28] + c_eval[29] - c_eval[33] + c_eval[34] - c_eval[35] - c_eval[36] + c_eval[37] - c_eval[38];
    c_reg_1[13][3] <=   c_eval[45] - c_eval[46] + c_eval[47] - c_eval[54] + c_eval[55] - c_eval[56] + c_eval[60] - c_eval[61] + c_eval[62];
    c_reg_1[13][4] <=   c_eval[63] - c_eval[64] + c_eval[65] - c_eval[72] + c_eval[73] - c_eval[74] + c_eval[78] - c_eval[79] + c_eval[80];

    c_reg_1[14][0] <= - c_eval[0]  + c_eval[2]  + c_eval[3]  - c_eval[6]  - c_eval[8]  + c_eval[9]  - c_eval[11] - c_eval[12];
    c_reg_1[14][1] <=   c_eval[15] - c_eval[18] + c_eval[20] + c_eval[21] - c_eval[24] + c_eval[26] + c_eval[27] - c_eval[29];
    c_reg_1[14][2] <= - c_eval[30] + c_eval[33] + c_eval[35] - c_eval[36] + c_eval[38] + c_eval[39] - c_eval[42] + c_eval[45];
    c_reg_1[14][3] <= - c_eval[47] - c_eval[48] + c_eval[51] - c_eval[54] + c_eval[56] + c_eval[57] - c_eval[60] - c_eval[62];
    c_reg_1[14][4] <=   c_eval[63] - c_eval[65] - c_eval[66] + c_eval[69] - c_eval[72] + c_eval[74] + c_eval[75] - c_eval[78] - c_eval[80];
    
    c_reg_1[15][0] <=   c_eval[0]  - c_eval[1]  + c_eval[2]  - c_eval[3]  + c_eval[4]  - c_eval[5]  + c_eval[6]  - c_eval[7];
    c_reg_1[15][1] <=   c_eval[8]  - c_eval[9]  + c_eval[10] - c_eval[11] + c_eval[12] - c_eval[13] + c_eval[14] - c_eval[15];
    c_reg_1[15][2] <=   c_eval[16] - c_eval[17] + c_eval[18] - c_eval[19] + c_eval[20] - c_eval[21] + c_eval[22] - c_eval[23];
    c_reg_1[15][3] <=   c_eval[24] - c_eval[25] + c_eval[26] - c_eval[27] + c_eval[28] - c_eval[29] + c_eval[30] - c_eval[31];
    c_reg_1[15][4] <=   c_eval[32] - c_eval[33] + c_eval[34] - c_eval[35] + c_eval[36] - c_eval[37] + c_eval[38] - c_eval[39];
    c_reg_1[15][5] <=   c_eval[40] - c_eval[41] + c_eval[42] - c_eval[43] + c_eval[44] - c_eval[45] + c_eval[46] - c_eval[47];
    c_reg_1[15][6] <=   c_eval[48] - c_eval[49] + c_eval[50] - c_eval[51] + c_eval[52] - c_eval[53] + c_eval[54] - c_eval[55];
    c_reg_1[15][7] <=   c_eval[56] - c_eval[57] + c_eval[58] - c_eval[59] + c_eval[60] - c_eval[61] + c_eval[62] - c_eval[63];
    c_reg_1[15][8] <=   c_eval[64] - c_eval[65] + c_eval[66] - c_eval[67] + c_eval[68] - c_eval[69] + c_eval[70] - c_eval[71];
    c_reg_1[15][9] <=   c_eval[72] - c_eval[73] + c_eval[74] - c_eval[75] + c_eval[76] - c_eval[77] + c_eval[78] - c_eval[79] + c_eval[80];

    // -----------------------------------------------------------------------
    // Stage 2
    // -----------------------------------------------------------------------
    

    // -----------------------------------------------------------------------
    // Stage 2
    // -----------------------------------------------------------------------


    // -----------------------------------------------------------------------
    // Stage 3-5: Barrett reduction
    // -----------------------------------------------------------------------
    genvar i;
    generate
        for (i=0; i<`N; i++) begin : barrett_reducers
            barrett_reduce u_barrett_reduce (
                .clk(clk),
                .rst_n(rst_n),
                .value_in(c_acc_reg[i]),
                .result_out(c[i])
            );
        end
    endgenerate

endmodule