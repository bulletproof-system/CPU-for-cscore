`timescale 1ns / 1ps
`default_nettype none

module Mux_RegWAC(
    input wire [1:0] RegWAC,
    input wire [4:0] D1,
    input wire [4:0] D2,
    output wire [4:0] out
    );
    assign out = (RegWAC == 2'b00) ? D1 : // Instr[15:11]
                 (RegWAC == 2'b01) ? D2 : // Instr[20:16]
                 (RegWAC == 2'b10) ? 5'h1F : 5'b0; // 11111
endmodule

module Mux_RegWDC(
    input wire [1:0] RegWDC,
    input wire [31:0] D1,
    input wire [31:0] D2,
    input wire [31:0] D3,
    output wire [31:0] out
    );
    assign out = (RegWDC == 2'b00) ? D1 : // ALU:out
                 (RegWDC == 2'b01) ? D2 : // DM:RD
                 (RegWDC == 2'b10) ? D3 : 5'b0; // PC_Calc:PC4
endmodule

module Mux_ALUSrc(
    input wire ALUSrc,
    input wire [31:0] D1,
    input wire [31:0] D2,
    output wire [31:0] out
);
    assign out = (ALUSrc == 1'b0) ? D1 : // GRF:RD2
                 D2; // Ext:imm32
endmodule //Mux

// module Mux_ (
    
// );

// endmodule //Mux
