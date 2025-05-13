`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////
// Polynomial Multiplication: 65536-point
// NTT*2: 3 Iterations, 4096 rounds per iteration
// Karatsuba unit: 16 -> 81 -> 16, 4096 rounds
// INTT: 3 Iterations, 4096 rounds per iteration
//////////////////////////////////////////////////////////////////////
`include "global_params.vh"

module Poly_top (
    input  logic  clk,
    input  logic  rst_n,

    input  logic  start,
    output logic  done,

    // Data IO for implementation
    // input  logic [`DATA_WIDTH-1:0] data_in_a,
    // input  logic [`DATA_WIDTH-1:0] data_in_b,
    output logic [`DATA_WIDTH-1:0] data_out_imp
);


// ==============================================
// Internal Signals
// ==============================================
// BRAM-A/B (C is stored in BRAM-A)
logic [`DATA_WIDTH-1:0]      BU_data_in_a[0:15];   // BRAM-A Data In
logic [`DATA_WIDTH-1:0]      BU_data_in_b[0:15];   // BRAM-B Data In

logic [`BRAM_ADDR_WIDTH-1:0] addr_rd[0:15];        // BRAM-A/B RD Addr
logic [15:0]                 index_rd[0:15];       // BRAM-A/B Index
logic [3:0]                  bank_rd[0:15];        // BRAM-A/B Bank
logic [7:0]                  bank_rd_temp[0:15];

logic                        we;                   // BRAM-A/B WR Enable   
logic                        wea;
logic                        web;         
logic [`BRAM_ADDR_WIDTH-1:0] addr_wr[0:15];        // BRAM-A/B WR Addr

logic [`DATA_WIDTH-1:0]      BU_data_out_a[0:15];  // BRAM-A Data Out
logic [`DATA_WIDTH-1:0]      BU_data_out_b[0:15];  // BRAM-B Data Out

logic [`DATA_WIDTH-1:0]      CWM_data_out_a[0:15]; // BRAM-A Data Out (CWM)
logic [`DATA_WIDTH-1:0]      CWM_data_out_b[0:15]; // BRAM-B Data Out (CWM)

logic [`ACC_WIDTH-1:0]       EVAL_a[0:80];          // Evaluation of a(x)
logic [`ACC_WIDTH-1:0]       EVAL_b[0:80];          // Evaluation of b(x)
logic [`MULT_WIDTH-1:0]      EVAL_c[0:80];          // Evaluation of c(x)

logic [`MULT_WIDTH-1:0]      INTERP_c[0:15];        // Interpolation of c(x)
logic [`DATA_WIDTH-1:0]      KARA_out[0:15];        // Barrett reduced output of Karatsuba

logic [`DATA_WIDTH-1:0]      data_out[0:15];       // Data Out of INTT

// WROM-NTT
logic [`WROM_ADDR_WIDTH-1:0] wrom_addr_ntt;   // WROM-NTT Addr
logic [`DATA_WIDTH-1:0]      twid_ntt[0:15];  // WROM-NTT Data

// WROM-INTT
logic [`WROM_ADDR_WIDTH-1:0] wrom_addr_intt;  // WROM-INTT Addr
logic [`DATA_WIDTH-1:0]      twid_intt[0:15]; // WROM-INTT Data

// cnt
logic [2:0]  cnt_iter;         // 0 -> 6
logic [12:0] cnt_round;        // 0 -> 4159 (4096+16*4)
logic [3:0]  cnt_gap;          // 0 -> 12

// ===============================================
// Finite State Machine (FSM)
// ===============================================
typedef enum logic [2:0] {
    IDLE,
    // DATA_IN,        // Load data into BRAM-A and BRAM-B
    NTT_ITER_0,     // NTT Iteration 0
    NTT_ITER_1,     // NTT Iteration 1
    KARA,           // NTT Iteration 2 + Karatsuba + INTT Iteration 0
    INTT_ITER_1,    // INTT Iteration 1
    INTT_ITER_0,    // INTT Iteration 2
    DATA_OUT,       // Read data from BRAM-C
    GAP             // Wait for the next iteration
} state_t;

state_t current_state, next_state;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end 
    else begin
        current_state <= next_state;
    end
end

always_comb begin
    case (current_state)
        IDLE: begin
            if (start) begin
                next_state = NTT_ITER_0;
            end 
            else begin
                next_state = IDLE;
            end
        end
        NTT_ITER_0: begin
            if (cnt_iter == 3'd0 && cnt_round == 13'd4095) begin
                next_state = GAP;
            end
            else begin
                next_state = NTT_ITER_0;
            end
        end
        NTT_ITER_1: begin
            if (cnt_iter == 3'd1 && cnt_round == 13'd4095) begin
                next_state = GAP;
            end
            else begin
                next_state = NTT_ITER_1;
            end
        end
        KARA: begin
            if (cnt_iter == 3'd2 && cnt_round == 13'd4159) begin
                next_state = GAP;
            end
            else begin
                next_state = KARA;
            end
        end
        INTT_ITER_1: begin
            if (cnt_iter == 3'd3 && cnt_round == 13'd4095) begin
                next_state = GAP;
            end
            else begin
                next_state = INTT_ITER_1;
            end
        end
        INTT_ITER_0: begin
            if (cnt_iter == 3'd4 && cnt_round == 13'd4095) begin
                next_state = GAP;
            end
            else begin
                next_state = INTT_ITER_0;
            end
        end
        DATA_OUT: begin
            if (cnt_iter == 3'd5 && cnt_round == 13'd4095) begin
                next_state = IDLE;
            end
            else begin
                next_state = DATA_OUT;
            end
        end
        GAP: begin
            if (cnt_gap == 4'd12) begin
                if (cnt_iter == 3'd0) begin
                    next_state = NTT_ITER_1;
                end
                else if (cnt_iter == 3'd1) begin
                    next_state = KARA;
                end
                else if (cnt_iter == 3'd2) begin
                    next_state = INTT_ITER_1;
                end
                else if (cnt_iter == 3'd3) begin
                    next_state = INTT_ITER_0;
                end
                else if (cnt_iter == 3'd4) begin
                    next_state = DATA_OUT;
                end
                else if (cnt_iter == 3'd5) begin
                    next_state = IDLE;
                end
            end
            else begin
                next_state = GAP;
            end
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

// ===============================================
// done signal
// ===============================================
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        done <= 1'b0;
    end 
    else begin
        if (cnt_iter == 3'd5 && cnt_gap == 4'd10) begin
            done <= 1'b1;
        end
        else if (start) begin
            done <= 1'b0;
        end
        else begin
            done <= done;
        end
    end
end

assign data_out_imp = data_out[0]; // Output the first element of the result

// ===============================================
// Counter
// ===============================================
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_iter <= 3'd0;
    end
    else begin
        if (next_state == NTT_ITER_0) begin
            cnt_iter <= 3'd0;
        end
        else if (next_state == NTT_ITER_1) begin
            cnt_iter <= 3'd1;
        end
        else if (next_state == KARA) begin
            cnt_iter <= 3'd2;
        end
        else if (next_state == INTT_ITER_1) begin
            cnt_iter <= 3'd3;
        end
        else if (next_state == INTT_ITER_0) begin
            cnt_iter <= 3'd4;
        end
        else if (next_state == DATA_OUT) begin
            cnt_iter <= 3'd5;
        end
        else begin
            cnt_iter <= cnt_iter;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_round <= 13'd0;
    end
    else begin
        if (next_state == NTT_ITER_0 || next_state == NTT_ITER_1) begin
            cnt_round <= cnt_round + 1'b1;
        end
        else if (next_state == KARA) begin
            cnt_round <= cnt_round + 1'b1;
        end
        else if (next_state == INTT_ITER_1 || next_state == INTT_ITER_0) begin
            cnt_round <= cnt_round + 1'b1;
        end
        else if (next_state == DATA_OUT) begin
            cnt_round <= cnt_round + 1'b1;
        end
        else begin
            cnt_round <= 13'd0;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_gap <= 4'd0;
    end
    else begin
        if (next_state == GAP) begin
            cnt_gap <= cnt_gap + 1'b1;
        end
        else begin
            cnt_gap <= 4'd0;
        end
    end
end

// ===============================================
// WROM Addr
// ===============================================
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wrom_addr_ntt <= 13'd0;
    end
    else begin
        if (next_state == NTT_ITER_0) begin
            wrom_addr_ntt <= cnt_round >> 8;       // cnt_round // 256
        end
        else if (next_state == NTT_ITER_1) begin
            wrom_addr_ntt <= cnt_round + 12'd16;   // cnt_round + 16
        end
        else if (next_state == KARA) begin
            wrom_addr_ntt <= cnt_round & 12'h00F;  // cnt_round % 16
        end
        else begin
            wrom_addr_ntt <= 13'd0;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wrom_addr_intt <= 13'd0;
    end
    else begin
        if (next_state == KARA) begin
            wrom_addr_intt <= (cnt_round - 12'd64) & 12'h00F;   // (cnt_round - 64) % 16
        end
        else if (next_state == INTT_ITER_1) begin
            wrom_addr_intt <= (cnt_round - 12'd64) + 12'd16;   // (cnt_round - 64) + 16
        end
        else if (next_state == INTT_ITER_0) begin
            wrom_addr_intt <= (cnt_round - 12'd64) >> 8;   // (cnt_round - 64) // 256
        end
        else begin
            wrom_addr_intt <= 13'd0;
        end
    end
end


// ================================================
// BRAM RD Addr
// ================================================
// 1. index_rd
always_comb begin
    if (next_state == NTT_ITER_0) begin
        for (int i=0; i<16; i=i+1) begin
            index_rd[i] = (i << 12) + cnt_round;                                           // i * 4096 + cnt_round
        end
    end
    else if (next_state == NTT_ITER_1) begin
        for (int i=0; i<16; i=i+1) begin
            index_rd[i] = ((i + ((cnt_round >> 8) << 4)) << 8) + (cnt_round & 12'h0FF);    // (i + ((cnt_round//256)*16) * 256) + (cnt_round % 256)
        end
    end
    else if (next_state == KARA) begin
        for (int i=0; i<16; i=i+1) begin
           // i*16 + 4096*((cnt_round//16)%16) + 256*(cnt_round//256) + (cnt_round%16)
            index_rd[i] = (i<<4) + (((cnt_round>>4) & 12'h00F)<<12) + ((cnt_round>>8)<<8) + (cnt_round & 12'h00F);
        end
    end
    else if (next_state == INTT_ITER_1) begin
        for (int i=0; i<16; i=i+1) begin
            index_rd[i] = ((i + ((cnt_round >> 8) << 4)) << 8) + (cnt_round & 12'h0FF);    // (i + ((cnt_round//256)*16) * 256) + (cnt_round % 256)
        end
    end
    else if (next_state == INTT_ITER_0) begin
        for (int i=0; i<16; i=i+1) begin
            index_rd[i] = ((i << 12) + cnt_round);                                           // i * 4096 + cnt_round
        end
    end
    else begin
        for (int i=0; i<16; i=i+1) begin
            index_rd[i] = 12'd0;
        end
    end 
end

// 2. bank_rd
always_comb begin
    for (int i=0; i<16; i=i+1) begin
        bank_rd_temp[i] = index_rd[i][15:12] + index_rd[i][11:8] + index_rd[i][7:4] + index_rd[i][3:0];
        bank_rd[i] = bank_rd_temp[i][3:0];
    end
end

// 3. addr_rd
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i=0; i<16; i=i+1) begin
            addr_rd[i] <= 12'd0;
        end
    end
    else begin
        if (next_state == NTT_ITER_0 || next_state == NTT_ITER_1 || next_state == KARA ||
            next_state == INTT_ITER_1 || next_state == INTT_ITER_0) begin
            for (int i=0; i<16; i=i+1) begin
                addr_rd[bank_rd[i]] <= index_rd[i][15:4];  
            end
        end
        else begin
            for (int i=0; i<16; i=i+1) begin
                addr_rd[i] <= 12'd0;
            end
        end
    end
end


// ================================================
// BRAM WR Addr
// ================================================
// 1. we
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        we <= 1'b0;
    end
    else begin
        if (cnt_iter == 0 || cnt_iter == 1) begin
            if (cnt_round == 13'd9) begin
                we <= 1'b1;
            end
            else if (cnt_gap == 4'd10) begin
                we <= 1'b0;
            end
            else begin
                we <= we;
            end
        end
        else if (cnt_iter == 2) begin
            if (cnt_round == 13'd73) begin    // 64+9
                we <= 1'b1;
            end
            else if (cnt_gap == 4'd10) begin
                we <= 1'b0;
            end
            else begin
                we <= we;
            end
        end
        else if (cnt_iter == 3 || cnt_iter == 4) begin
            if (cnt_round == 13'd9) begin
                we <= 1'b1;
            end
            else if (cnt_gap == 4'd10) begin
                we <= 1'b0;
            end
            else begin
                we <= we;
            end
        end
        else begin
            we <= 1'b0;
        end
    end
end

assign wea = we;
always_comb begin
    if (cnt_iter<2) begin
        web = we;
    end
    else begin
        web = 1'b0;
    end
end
            
// 2. addr_wr
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i=0; i<16; i=i+1) begin
            addr_wr[i] <= 12'd0;
        end
    end
    else begin
        for (int i=0; i<16; i=i+1) begin
            addr_wr[i] <= addr_rd[i];
        end
    end
end

// ===============================================
// NTT instantiation: CT_BU_array
// ===============================================
CT_BU_array u0_CT_BU_array(
    .clk(clk),
    .rst_n(rst_n),

    .din(BU_data_in_a),
    .dout(BU_data_out_a)
);

CT_BU_array u1_CT_BU_array(
    .clk(clk),
    .rst_n(rst_n),

    .din(BU_data_in_b),
    .dout(BU_data_out_b)
);

genvar m;
generate
    for (m = 0; m < 16; m = m + 1) begin: cwm_a
        mod_mult_barrett u0_mod_mult_barrett(
            .clk(clk),
            .rst_n(rst_n),

            .A(BU_data_out_a[m]),
            .B(twid_ntt[m]),
            .C(CWM_data_out_a[m])
        );
        mod_mult_barrett u1_mod_mult_barrett(
            .clk(clk),
            .rst_n(rst_n),

            .A(BU_data_out_b[m]),
            .B(twid_ntt[m]),
            .C(CWM_data_out_b[m])
        );
    end
endgenerate

// ===============================================
// Karatsuba instantiation
// ===============================================
// Stage 1: Evaluation of a(x) and b(x)
evaluation eval_a_b (
    .clk(clk),
    .rst_n(rst_n),
    .a(CWM_data_out_a),
    .b(CWM_data_out_b),
    .a_eval(EVAL_a),
    .b_eval(EVAL_b)
);

// Stage 2: Element-wise multiplication
elementwise_mult elem_mult (
    .clk(clk),
    .rst_n(rst_n),
    .a_eval(EVAL_a),
    .b_eval(EVAL_b),
    .c_eval(EVAL_c)
);

// Stage 3: Interpolation
interpolation interp (
    .clk(clk),
    .rst_n(rst_n),
    .c_eval(EVAL_c),
    .c(INTERP_c)
);

// Stage 4: Barrett reduction
genvar k;
generate
    for (k = 0; k < 16; k = k + 1) begin : barrett_reducers
        barrett_reduce u_barrett_reduce (
            .clk(clk),
            .rst_n(rst_n),
            .value_in(INTERP_c[k]),
            .result_out(KARA_out[k])
        );
    end
endgenerate

// ================================================
// INTT instantiation: GS_BU_array
// ================================================
GS_BU_array u0_GS_BU_array(
    .clk(clk),
    .rst_n(rst_n),

    .din(KARA_out),
    .dout(data_out)
);


// ================================================
// BRAM instantiation
// ================================================
genvar i_bram;
generate
    for (i_bram = 0; i_bram < 16; i_bram = i_bram + 1) begin: bram_bank
        BRAM #(
            .DLEN(`DATA_WIDTH),  // 30 bits
            .HLEN(`BRAM_ADDR_WIDTH)  // 4096 = 2^12 
        ) u_a_bram (
            .clk(clk),
            .wen(wea), 
            .waddr(addr_wr[i_bram]),
            .din(CWM_data_out_a[i_bram]),
            .raddr(addr_rd[i_bram]),
            .dout(BU_data_in_a[i_bram])
        );
        
        BRAM #(
            .DLEN(`DATA_WIDTH),  // 30 bits
            .HLEN(`BRAM_ADDR_WIDTH)  // 4096 = 2^12 
        ) u_b_bram (
            .clk(clk),
            .wen(web), 
            .waddr(addr_wr[i_bram]),
            .din(CWM_data_out_b[i_bram]),
            .raddr(addr_rd[i_bram]),
            .dout(BU_data_in_b[i_bram])
        );
    end
endgenerate

// ================================================
// WROM instantiation
// ================================================
genvar j;
generate
    for (j = 0; j < 16; j = j + 1) begin: wrom_bank
        WROM #(
            .DLEN(30),             // Data Width
            .HLEN(13)              // Addr Width
        ) u_ntt_wrom (
            .clk(clk),
            .raddr(wrom_addr_ntt),     // RD Addr
            .dout(twid_ntt[j])       // RD Data
        );

        WROM #(
            .DLEN(30),             // Data Width
            .HLEN(13)              // Addr Width
        ) u_intt_wrom (
            .clk(clk),
            .raddr(wrom_addr_intt),     // RD Addr
            .dout(twid_intt[j])       // RD Data
        );
    end
endgenerate


endmodule