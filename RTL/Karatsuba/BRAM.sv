`timescale 1ns / 1ps

module BRAM #(
    parameter DLEN = 30,             // Data Width
    parameter HLEN = 12,             // Addr Width
    parameter INIT_FILE = "none"     // Initialization File
)(
    input  logic            clk,
    input  logic            wen,       // WR Enable
    input  logic [HLEN-1:0] waddr,     // WR Addr
    input  logic [DLEN-1:0] din,       // WR Data
    input  logic [HLEN-1:0] raddr,     // RD Addr
    output logic [DLEN-1:0] dout       // RD Data
);

// Set Attribute for Block RAM
(* ram_style="block" *) logic [DLEN-1:0] blockram [(1<<HLEN)-1:0];

// Initialize BRAM
initial begin
    if (INIT_FILE != "none") begin
        $readmemh(INIT_FILE, blockram);
    end
end

// WR Operation
always @(posedge clk) begin
    if (wen) blockram[waddr] <= din;
end

// RD Operation
always @(posedge clk) begin
    dout <= blockram[raddr];
end

endmodule