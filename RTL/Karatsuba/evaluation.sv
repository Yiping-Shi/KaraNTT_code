// evaluation_module.sv
// Implementation of polynomial evaluation using sparse CSC format

`timescale 1ns / 1ps
`include "global_params.vh"

module evaluation (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic [`DATA_WIDTH-1:0] a[0:`N-1],               // Coefficients of the polynomial a(x)
    input  logic [`DATA_WIDTH-1:0] b[0:`N-1],               // Coefficients of the polynomial b(x)
    output logic [`ACC_WIDTH-1:0]  a_eval[0:`EVAL_ROWS-1],  // Evaluation of a(x)
    output logic [`ACC_WIDTH-1:0]  b_eval[0:`EVAL_ROWS-1]   // Evaluation of b(x)
);

    // Internal signals (used for pipeline stages)
    logic [`DATA_WIDTH-1:0] a_reg[0:`N-1];
    logic [`DATA_WIDTH-1:0] b_reg[0:`N-1];
    
    logic [`ACC_WIDTH-1:0]  a_mid[0:1];
    logic [`ACC_WIDTH-1:0]  b_mid[0:1];

    //-------------------------------------------------------------------------
    // Stage 1
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<`N; i++) begin
                a_reg[i] <= '0;
                b_reg[i] <= '0;
            end
        end
        else begin
            for (int i=0; i<`N; i++) begin
                a_reg[i] <= a[i];
                b_reg[i] <= b[i];
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_mid[0] <= '0;
            b_mid[0] <= '0;
            a_mid[1] <= '0;
            b_mid[1] <= '0;
        end
        else begin
            a_mid[0] <= a[0] + a[1] + a[2]  + a[3]  + a[4]  + a[5]  + a[6]  + a[7];
            b_mid[0] <= b[0] + b[1] + b[2]  + b[3]  + b[4]  + b[5]  + b[6]  + b[7];
            a_mid[1] <= a[8] + a[9] + a[10] + a[11] + a[12] + a[13] + a[14] + a[15];
            b_mid[1] <= b[8] + b[9] + b[10] + b[11] + b[12] + b[13] + b[14] + b[15];
        end
    end

    //-------------------------------------------------------------------------
    // Stage 2
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<`EVAL_ROWS; i++) begin
                a_eval[i] <= '0;
                b_eval[i] <= '0;
            end
        end
        else begin
            a_eval[0]  <= a_reg[0];
            a_eval[1]  <= a_reg[0] + a_reg[1];
            a_eval[2]  <= a_reg[1];
            a_eval[3]  <= a_reg[0] + a_reg[2];
            a_eval[4]  <= a_reg[0] + a_reg[1] + a_reg[2] + a_reg[3];
            a_eval[5]  <= a_reg[1] + a_reg[3];
            a_eval[6]  <= a_reg[2];
            a_eval[7]  <= a_reg[2] + a_reg[3];
            a_eval[8]  <= a_reg[3];
            a_eval[9]  <= a_reg[0] + a_reg[4];
            a_eval[10] <= a_reg[0] + a_reg[1] + a_reg[4] + a_reg[5];
            a_eval[11] <= a_reg[1] + a_reg[5];
            a_eval[12] <= a_reg[0] + a_reg[2] + a_reg[4] + a_reg[6];
            a_eval[13] <= a_reg[0] + a_reg[1] + a_reg[2] + a_reg[3] + a_reg[4] + a_reg[5] + a_reg[6] + a_reg[7];
            a_eval[14] <= a_reg[1] + a_reg[3] + a_reg[5] + a_reg[7];
            a_eval[15] <= a_reg[2] + a_reg[6];
            a_eval[16] <= a_reg[2] + a_reg[3] + a_reg[6] + a_reg[7];
            a_eval[17] <= a_reg[3] + a_reg[7];
            a_eval[18] <= a_reg[4];
            a_eval[19] <= a_reg[4] + a_reg[5];
            a_eval[20] <= a_reg[5];
            a_eval[21] <= a_reg[4] + a_reg[6];
            a_eval[22] <= a_reg[4] + a_reg[5] + a_reg[6] + a_reg[7];
            a_eval[23] <= a_reg[5] + a_reg[7];
            a_eval[24] <= a_reg[6];
            a_eval[25] <= a_reg[6] + a_reg[7];
            a_eval[26] <= a_reg[7];
            a_eval[27] <= a_reg[0] + a_reg[8];
            a_eval[28] <= a_reg[0] + a_reg[1] + a_reg[8] + a_reg[9];
            a_eval[29] <= a_reg[1] + a_reg[9];
            a_eval[30] <= a_reg[0] + a_reg[2] + a_reg[8] + a_reg[10];
            a_eval[31] <= a_reg[0] + a_reg[1] + a_reg[2] + a_reg[3] + a_reg[8] + a_reg[9] + a_reg[10] + a_reg[11];
            a_eval[32] <= a_reg[1] + a_reg[3] + a_reg[9] + a_reg[11];
            a_eval[33] <= a_reg[2] + a_reg[10];
            a_eval[34] <= a_reg[2] + a_reg[3] + a_reg[10] + a_reg[11];
            a_eval[35] <= a_reg[3] + a_reg[11];
            a_eval[36] <= a_reg[0] + a_reg[4] + a_reg[8] + a_reg[12];
            a_eval[37] <= a_reg[0] + a_reg[1] + a_reg[4] + a_reg[5] + a_reg[8] + a_reg[9] + a_reg[12] + a_reg[13];
            a_eval[38] <= a_reg[1] + a_reg[5] + a_reg[9] + a_reg[13];
            a_eval[39] <= a_reg[0] + a_reg[2] + a_reg[4] + a_reg[6] + a_reg[8] + a_reg[10] + a_reg[12] + a_reg[14];
            a_eval[40] <= a_mid[0] + a_mid[1];
            a_eval[41] <= a_reg[1] + a_reg[3] + a_reg[5] + a_reg[7] + a_reg[9] + a_reg[11] + a_reg[13] + a_reg[15];
            a_eval[42] <= a_reg[2] + a_reg[6] + a_reg[10] + a_reg[14];
            a_eval[43] <= a_reg[2] + a_reg[3] + a_reg[6] + a_reg[7] + a_reg[10] + a_reg[11] + a_reg[14] + a_reg[15];
            a_eval[44] <= a_reg[3] + a_reg[7] + a_reg[11] + a_reg[15];
            a_eval[45] <= a_reg[4] + a_reg[12];
            a_eval[46] <= a_reg[4] + a_reg[5] + a_reg[12] + a_reg[13];
            a_eval[47] <= a_reg[5] + a_reg[13];
            a_eval[48] <= a_reg[4] + a_reg[6] + a_reg[12] + a_reg[14];
            a_eval[49] <= a_reg[4] + a_reg[5] + a_reg[6] + a_reg[7] + a_reg[12] + a_reg[13] + a_reg[14] + a_reg[15];
            a_eval[50] <= a_reg[5] + a_reg[7] + a_reg[13] + a_reg[15];
            a_eval[51] <= a_reg[6] + a_reg[14];
            a_eval[52] <= a_reg[6] + a_reg[7] + a_reg[14] + a_reg[15];
            a_eval[53] <= a_reg[7] + a_reg[15];
            a_eval[54] <= a_reg[8];
            a_eval[55] <= a_reg[8] + a_reg[9];
            a_eval[56] <= a_reg[9];
            a_eval[57] <= a_reg[8] + a_reg[10];
            a_eval[58] <= a_reg[8] + a_reg[9] + a_reg[10] + a_reg[11];
            a_eval[59] <= a_reg[9] + a_reg[11];
            a_eval[60] <= a_reg[10];
            a_eval[61] <= a_reg[10] + a_reg[11];
            a_eval[62] <= a_reg[11];
            a_eval[63] <= a_reg[8] + a_reg[12];
            a_eval[64] <= a_reg[8] + a_reg[9] + a_reg[12] + a_reg[13];
            a_eval[65] <= a_reg[9] + a_reg[13];
            a_eval[66] <= a_reg[8] + a_reg[10] + a_reg[12] + a_reg[14];
            a_eval[67] <= a_reg[8] + a_reg[9] + a_reg[10] + a_reg[11] + a_reg[12] + a_reg[13] + a_reg[14] + a_reg[15];
            a_eval[68] <= a_reg[9] + a_reg[11] + a_reg[13] + a_reg[15];
            a_eval[69] <= a_reg[10] + a_reg[14];
            a_eval[70] <= a_reg[10] + a_reg[11] + a_reg[14] + a_reg[15];
            a_eval[71] <= a_reg[11] + a_reg[15];
            a_eval[72] <= a_reg[12];
            a_eval[73] <= a_reg[12] + a_reg[13];
            a_eval[74] <= a_reg[13];
            a_eval[75] <= a_reg[12] + a_reg[14];
            a_eval[76] <= a_reg[12] + a_reg[13] + a_reg[14] + a_reg[15];
            a_eval[77] <= a_reg[13] + a_reg[15];
            a_eval[78] <= a_reg[14];
            a_eval[79] <= a_reg[14] + a_reg[15];
            a_eval[80] <= a_reg[15];
            
            b_eval[0]  <= b_reg[0];
            b_eval[1]  <= b_reg[0] + b_reg[1];
            b_eval[2]  <= b_reg[1];
            b_eval[3]  <= b_reg[0] + b_reg[2];
            b_eval[4]  <= b_reg[0] + b_reg[1] + b_reg[2] + b_reg[3];
            b_eval[5]  <= b_reg[1] + b_reg[3];
            b_eval[6]  <= b_reg[2];
            b_eval[7]  <= b_reg[2] + b_reg[3];
            b_eval[8]  <= b_reg[3];
            b_eval[9]  <= b_reg[0] + b_reg[4];
            b_eval[10] <= b_reg[0] + b_reg[1] + b_reg[4] + b_reg[5];
            b_eval[11] <= b_reg[1] + b_reg[5];
            b_eval[12] <= b_reg[0] + b_reg[2] + b_reg[4] + b_reg[6];
            b_eval[13] <= b_reg[0] + b_reg[1] + b_reg[2] + b_reg[3] + b_reg[4] + b_reg[5] + b_reg[6] + b_reg[7];
            b_eval[14] <= b_reg[1] + b_reg[3] + b_reg[5] + b_reg[7];
            b_eval[15] <= b_reg[2] + b_reg[6];
            b_eval[16] <= b_reg[2] + b_reg[3] + b_reg[6] + b_reg[7];
            b_eval[17] <= b_reg[3] + b_reg[7];
            b_eval[18] <= b_reg[4];
            b_eval[19] <= b_reg[4] + b_reg[5];
            b_eval[20] <= b_reg[5];
            b_eval[21] <= b_reg[4] + b_reg[6];
            b_eval[22] <= b_reg[4] + b_reg[5] + b_reg[6] + b_reg[7];
            b_eval[23] <= b_reg[5] + b_reg[7];
            b_eval[24] <= b_reg[6];
            b_eval[25] <= b_reg[6] + b_reg[7];
            b_eval[26] <= b_reg[7];
            b_eval[27] <= b_reg[0] + b_reg[8];
            b_eval[28] <= b_reg[0] + b_reg[1] + b_reg[8] + b_reg[9];
            b_eval[29] <= b_reg[1] + b_reg[9];
            b_eval[30] <= b_reg[0] + b_reg[2] + b_reg[8] + b_reg[10];
            b_eval[31] <= b_reg[0] + b_reg[1] + b_reg[2] + b_reg[3] + b_reg[8] + b_reg[9] + b_reg[10] + b_reg[11];
            b_eval[32] <= b_reg[1] + b_reg[3] + b_reg[9] + b_reg[11];
            b_eval[33] <= b_reg[2] + b_reg[10];
            b_eval[34] <= b_reg[2] + b_reg[3] + b_reg[10] + b_reg[11];
            b_eval[35] <= b_reg[3] + b_reg[11];
            b_eval[36] <= b_reg[0] + b_reg[4] + b_reg[8] + b_reg[12];
            b_eval[37] <= b_reg[0] + b_reg[1] + b_reg[4] + b_reg[5] + b_reg[8] + b_reg[9] + b_reg[12] + b_reg[13];
            b_eval[38] <= b_reg[1] + b_reg[5] + b_reg[9] + b_reg[13];
            b_eval[39] <= b_reg[0] + b_reg[2] + b_reg[4] + b_reg[6] + b_reg[8] + b_reg[10] + b_reg[12] + b_reg[14];
            b_eval[40] <= b_mid[0] + b_mid[1];
            b_eval[41] <= b_reg[1] + b_reg[3] + b_reg[5] + b_reg[7] + b_reg[9] + b_reg[11] + b_reg[13] + b_reg[15];
            b_eval[42] <= b_reg[2] + b_reg[6] + b_reg[10] + b_reg[14];
            b_eval[43] <= b_reg[2] + b_reg[3] + b_reg[6] + b_reg[7] + b_reg[10] + b_reg[11] + b_reg[14] + b_reg[15];
            b_eval[44] <= b_reg[3] + b_reg[7] + b_reg[11] + b_reg[15];
            b_eval[45] <= b_reg[4] + b_reg[12];
            b_eval[46] <= b_reg[4] + b_reg[5] + b_reg[12] + b_reg[13];
            b_eval[47] <= b_reg[5] + b_reg[13];
            b_eval[48] <= b_reg[4] + b_reg[6] + b_reg[12] + b_reg[14];
            b_eval[49] <= b_reg[4] + b_reg[5] + b_reg[6] + b_reg[7] + b_reg[12] + b_reg[13] + b_reg[14] + b_reg[15];
            b_eval[50] <= b_reg[5] + b_reg[7] + b_reg[13] + b_reg[15];
            b_eval[51] <= b_reg[6] + b_reg[14];
            b_eval[52] <= b_reg[6] + b_reg[7] + b_reg[14] + b_reg[15];
            b_eval[53] <= b_reg[7] + b_reg[15];
            b_eval[54] <= b_reg[8];
            b_eval[55] <= b_reg[8] + b_reg[9];
            b_eval[56] <= b_reg[9];
            b_eval[57] <= b_reg[8] + b_reg[10];
            b_eval[58] <= b_reg[8] + b_reg[9] + b_reg[10] + b_reg[11];
            b_eval[59] <= b_reg[9] + b_reg[11];
            b_eval[60] <= b_reg[10];
            b_eval[61] <= b_reg[10] + b_reg[11];
            b_eval[62] <= b_reg[11];
            b_eval[63] <= b_reg[8] + b_reg[12];
            b_eval[64] <= b_reg[8] + b_reg[9] + b_reg[12] + b_reg[13];
            b_eval[65] <= b_reg[9] + b_reg[13];
            b_eval[66] <= b_reg[8] + b_reg[10] + b_reg[12] + b_reg[14];
            b_eval[67] <= b_reg[8] + b_reg[9] + b_reg[10] + b_reg[11] + b_reg[12] + b_reg[13] + b_reg[14] + b_reg[15];
            b_eval[68] <= b_reg[9] + b_reg[11] + b_reg[13] + b_reg[15];
            b_eval[69] <= b_reg[10] + b_reg[14];
            b_eval[70] <= b_reg[10] + b_reg[11] + b_reg[14] + b_reg[15];
            b_eval[71] <= b_reg[11] + b_reg[15];
            b_eval[72] <= b_reg[12];
            b_eval[73] <= b_reg[12] + b_reg[13];
            b_eval[74] <= b_reg[13];
            b_eval[75] <= b_reg[12] + b_reg[14];
            b_eval[76] <= b_reg[12] + b_reg[13] + b_reg[14] + b_reg[15];
            b_eval[77] <= b_reg[13] + b_reg[15];
            b_eval[78] <= b_reg[14];
            b_eval[79] <= b_reg[14] + b_reg[15];
            b_eval[80] <= b_reg[15];
        end
    end
    

endmodule