`timescale 1ns / 1ps
`default_nettype none

module Extend(
    input wire [15:0] imm,
    input wire [1:0] Ext,
    output wire [31:0] imm32
    );
    assign imm32 = (Ext == 2'b00) ? {16'b0, imm} : // zero_ext
                   (Ext == 2'b01) ? {{16{imm[15]}}, imm} : // sign_ext
                   (Ext == 2'b10) ? {imm, 16'b0} : // lui
                   32'b0;
endmodule
