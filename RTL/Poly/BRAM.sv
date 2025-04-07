`timescale 1ns / 1ps

module BRAM #(
    parameter DLEN = 30,             // Data Width
    parameter HLEN = 12             // Addr Width
)(
    input  logic            clk,
    input  logic            wen,       // WR Enable
    input  logic [HLEN-1:0] waddr,     // WR Addr
    input  logic [DLEN-1:0] din,       // WR Data
    input  logic [HLEN-1:0] raddr,     // RD Addr
    output logic [DLEN-1:0] dout       // RD Data
);

// Set Attribute for Block RAM
(* ram_style="block" *) logic [DLEN-1:0] bram [(1<<HLEN)-1:0];

// WR Operation
always @(posedge clk) begin
    if (wen) bram[waddr] <= din;
end

// RD Operation
always @(posedge clk) begin
    dout <= bram[raddr];
end

endmodule