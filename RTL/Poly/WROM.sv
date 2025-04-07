`timescale 1ns / 1ps

module WROM #(
    parameter DLEN = 30,             // Data Width
    parameter HLEN = 12              // Addr Width
)(
    input  logic            clk,
    input  logic [HLEN-1:0] raddr,     // RD Addr
    output logic [DLEN-1:0] dout       // RD Data
);

// Set Attribute for Block RAM
(* ram_style="block" *) logic [DLEN-1:0] wrom [(1<<HLEN)-1:0];

// RD Operation
always @(posedge clk) begin
    dout <= wrom[raddr];
end

endmodule