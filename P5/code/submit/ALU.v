`timescale 1ns / 1ps
`default_nettype none
`include "Gobals.v"

module ALU(
    input wire [31:0] D1,
    input wire [31:0] D2,
	input wire [15:0] Imm,
    input wire [5:0]  ALUop,
	input wire ALUSrc,
    input wire Ext,
    output wire [31:0] out
    );
	wire [31:0] A, B, Imm32;
	assign Imm32 = Ext ? {{16{Imm[15]}}, Imm} : {16'b0, Imm};
	assign A = D1;
	assign B = ALUSrc ? Imm32 : D2;
    assign out = (ALUop == `ALU_add) ? A + B :
                 (ALUop == `ALU_sub) ? A - B :
                 (ALUop == `ALU_and) ? A & B :
                 (ALUop == `ALU_or ) ? A | B :
                 (ALUop == `ALU_slt) ? (($signed(A) < $signed(B)) ? 32'd1 : 32'd0) :
                 (ALUop == `ALU_sltu) ? ((A < B) ? 32'd1 : 32'd0) :
                 (ALUop == `ALU_addu) ? A + B :
                 (ALUop == `ALU_subu) ? A - B :
                 (ALUop == `ALU_sll ) ? B << Imm[10:6] :
                 (ALUop == `ALU_lui) ? {Imm, 16'b0} :
                 32'b0;
endmodule