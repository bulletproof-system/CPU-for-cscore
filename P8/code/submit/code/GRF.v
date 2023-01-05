`timescale 1ns / 1ps
`default_nettype none
`include "Gobals.v"

`timescale 1ns / 1ps
`default_nettype none

module GRF(
    input wire clk,
    input wire reset,
    input wire [4:0] RA1,
    input wire [4:0] RA2,
    input wire RegWrite,
    input wire [4:0] WA,
    input wire [31:0] WD,
    output wire [31:0] RD1,
    output wire [31:0] RD2
    );
    integer i;
    reg [31:0] grf [31:0];
    assign RD1 = (RA1 == 5'b0) ? 32'b0 : 
                 (RegWrite && RA1 == WA) ? WD : grf[RA1];
    assign RD2 = (RA2 == 5'b0) ? 32'b0 :
                 (RegWrite && RA2 == WA) ? WD : grf[RA2];
    always @(posedge clk) begin
        if (reset) begin
            for(i=0;i<32;i=i+1) grf[i] <= 32'b0;
        end else begin
            if(RegWrite) begin
                grf[WA] <= WD;
            end else;
        end
    end
endmodule
