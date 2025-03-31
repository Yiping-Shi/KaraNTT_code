`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// NTT: 16-point
// Group size: 1, 2, 4, 8
// BF: Cooley-Tukey
// 
//////////////////////////////////////////////////////////////////////////////////
`include "global_params.vh"

module NTT_16(
    input  logic clk,
    input  logic rst_n,

    input  logic [`DATA_WIDTH-1:0] din[0:15],
    output logic [`DATA_WIDTH-1:0] dout[0:15]
);

// Internal signals
logic [`DATA_WIDTH-1:0] stage_0[0:15];
logic [`DATA_WIDTH-1:0] stage_1[0:15];
logic [`DATA_WIDTH-1:0] stage_2[0:15];
logic [`DATA_WIDTH-1:0] stage_3[0:15];

logic [`DATA_WIDTH-1:0] r_stage_0[0:15];
logic [`DATA_WIDTH-1:0] r_stage_1[0:15];
logic [`DATA_WIDTH-1:0] r_stage_2[0:15];
logic [`DATA_WIDTH-1:0] r_stage_3[0:15];

// ---------------------------------------------------------
// Stage 0: 16-point NTT
// ---------------------------------------------------------
ct_butterfly_stage0 u_ct_butterfly_stage0 (
    .din(din),
    .dout(stage_0)
);

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i=0; i<16; i++) begin
            r_stage_0[i] <= 0;
        end
    end
    else begin
        for (int i=0; i<16; i++) begin
            r_stage_0[i] <= stage_0[i];
        end
    end
end

// ---------------------------------------------------------
// Stage 1: 16-point NTT
// ---------------------------------------------------------
ct_butterfly_stage1 u_ct_butterfly_stage1 (
    .din(r_stage_0),
    .dout(stage_1)
);

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i=0; i<16; i++) begin
            r_stage_1[i] <= 0;
        end
    end
    else begin
        for (int i=0; i<16; i++) begin
            r_stage_1[i] <= stage_1[i];
        end
    end
end

// ---------------------------------------------------------
// Stage 2: 16-point NTT
// ---------------------------------------------------------
ct_butterfly_stage2 u_ct_butterfly_stage2 (
    .din(r_stage_1),
    .dout(stage_2)
);

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i=0; i<16; i++) begin
            r_stage_2[i] <= 0;
        end
    end
    else begin
        for (int i=0; i<16; i++) begin
            r_stage_2[i] <= stage_2[i];
        end
    end
end

// ---------------------------------------------------------
// Stage 3: 16-point NTT
// ---------------------------------------------------------
ct_butterfly_stage3 u_ct_butterfly_stage3 (
    .din(r_stage_2),
    .dout(stage_3)
);
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i=0; i<16; i++) begin
            r_stage_3[i] <= 0;
        end
    end
    else begin
        for (int i=0; i<16; i++) begin
            r_stage_3[i] <= stage_3[i];
        end
    end
end

// ---------------------------------------------------------
// Output
// ---------------------------------------------------------
always_comb begin
    for (int i=0; i<16; i++) begin
        dout[i] = r_stage_3[i];
    end
end

endmodule