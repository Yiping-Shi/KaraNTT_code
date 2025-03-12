// karatsuba_multiplier.sv
// Karatsuba polynomial multiplier implementation

`timescale 1ns / 1ps
`include "global_params.vh"

module top_karatsuba_multiplier (
    input  logic                   clk,
    input  logic                   rst_n,
    output logic [`DATA_WIDTH-1:0] c[`N-1:0]  // Coefficients of the polynomial c(x)
);

    // Internal signals (used for pipeline stages)
    logic [`DATA_WIDTH-1:0] a[`N-1:0];        // Coefficients of the polynomial a(x)
    logic [`DATA_WIDTH-1:0] b[`N-1:0];        // Coefficients of the polynomial b(x)

    logic [`ACC_WIDTH-1:0]  a_eval[`EVAL_ROWS-1:0];
    logic [`ACC_WIDTH-1:0]  b_eval[`EVAL_ROWS-1:0];
    logic [`MULT_WIDTH-1:0] c_eval[`EVAL_ROWS-1:0];
    logic [`MULT_WIDTH-1:0] c_temp[`N-1:0];

    logic [`BRAM_DEPTH-1:0] raddr;      // BRAM read address

    // -----------------------------------------------------------------------
    // Stage 0: Instantiate BRAMs for storing a(x) and b(x)
    // -----------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            raddr <= '0;
        end 
        else begin
            raddr <= raddr + 1'b1;
        end
    end

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin: bram_bank
            BRAM #(
                .DLEN(`DATA_WIDTH),  // 30 bits
                .HLEN(`BRAM_DEPTH),  // 4096 = 2^12
                .INIT_FILE($sformatf("D:\\IDEA\\NTT_Kara_25\\KaraNTT_code\\Scripts\\BRAM_mem_files\\bank_%0d.txt", i))  
            ) u_a_bram (
                .clk(clk),
                .wen(), 
                .waddr(),
                .din(),
                .raddr(raddr),
                .dout(a[i])
            );

            BRAM #(
                .DLEN(`DATA_WIDTH),  // 30 bits
                .HLEN(`BRAM_DEPTH),  // 4096 = 2^12
                .INIT_FILE($sformatf("D:\\IDEA\\NTT_Kara_25\\KaraNTT_code\\Scripts\\BRAM_mem_files\\bank_%0d.txt", i))  
            ) u_b_bram (
                .clk(clk),
                .wen(), 
                .waddr(),
                .din(),
                .raddr(raddr),
                .dout(b[i])
            );
        end
    endgenerate

    // -----------------------------------------------------------------------
    // Stage 1: Evaluation of a(x) and b(x)
    // -----------------------------------------------------------------------
    evaluation eval_a_b (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .a_eval(a_eval),
        .b_eval(b_eval)
    );

    // -----------------------------------------------------------------------
    // Stage 2: Element-wise multiplication
    // -----------------------------------------------------------------------
    elementwise_mult elem_mult (
        .clk(clk),
        .rst_n(rst_n),
        .a_eval(a_eval),
        .b_eval(b_eval),
        .c_eval(c_eval)
    );

    // -----------------------------------------------------------------------
    // Stage 3: Interpolation
    // -----------------------------------------------------------------------
    interpolation interp (
        .clk(clk),
        .rst_n(rst_n),
        .c_eval(c_eval),
        .c(c_temp)
    );

    // -----------------------------------------------------------------------
    // Stage 4: Barrett reduction
    // -----------------------------------------------------------------------
    genvar j;
    generate
        for (j=0; j<`N; j++) begin : barrett_reducers
            barrett_reduce u_barrett_reduce (
                .clk(clk),
                .rst_n(rst_n),
                .value_in(c_temp[j]),
                .result_out(c[j])
            );
        end
    endgenerate

endmodule