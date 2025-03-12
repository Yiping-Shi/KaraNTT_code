`timescale 1ns / 1ps

module WROM #(
    parameter DLEN = 30,             // Data Width
    parameter HLEN = 12,             // Addr Width
    parameter INIT_FILE = "none"     // Initialization File
)(
    input  logic            clk,
    input  logic [HLEN-1:0] raddr,     // RD Addr
    output logic [DLEN-1:0] dout       // RD Data
);

// Set Attribute for Block RAM
(* ram_style="block" *) logic [DLEN-1:0] wrom [(1<<HLEN)-1:0];

// Initialize BRAM
initial begin
    if (INIT_FILE != "none") begin
        $readmemh(INIT_FILE, wrom);
    end
end

// RD Operation
always @(posedge clk) begin
    dout <= wrom[raddr];
end

endmodule