`timescale 1ns / 1ps
`default_nettype none
`include "Gobals.v"

module Mux_1_2 (
	input wire Sel,
	input wire [31:0] D0,
	input wire [31:0] D1,
	output wire [31:0] out
);
	assign out = Sel ? D1 : D0;
endmodule //Mux_1_2
module Mux_1_2_5bit (
	input wire Sel,
	input wire [4:0] D0,
	input wire [4:0] D1,
	output wire [4:0] out
);
	assign out = Sel ? D1 : D0;
endmodule //Mux_1_2_5bit

module Mux_2_4 (
	input wire [1:0] Sel,
	input wire [31:0] D0,
	input wire [31:0] D1,
	input wire [31:0] D2,
	input wire [31:0] D3,
	output wire [31:0] out
);
	assign out = (Sel == 2'd0) ? D0 :
				 (Sel == 2'd1) ? D1 :
				 (Sel == 2'd2) ? D2 : D3;
endmodule //Mux_2_4

module Mux_2_4_5bit (
	input wire [1:0] Sel,
	input wire [4:0] D0,
	input wire [4:0] D1,
	input wire [4:0] D2,
	input wire [4:0] D3,
	output wire [4:0] out
);
	assign out = (Sel == 2'd0) ? D0 :
				 (Sel == 2'd1) ? D1 :
				 (Sel == 2'd2) ? D2 : D3;
endmodule //Mux_2_4_5bit

module Mux_3_8 (
	input wire [2:0] Sel,
	input wire [31:0] D0,
	input wire [31:0] D1,
	input wire [31:0] D2,
	input wire [31:0] D3,
	input wire [31:0] D4,
	input wire [31:0] D5,
	input wire [31:0] D6,
	input wire [31:0] D7,
	output wire [31:0] out
);
	assign out = (Sel == 3'd0) ? D0 :
				 (Sel == 3'd1) ? D1 :
				 (Sel == 3'd2) ? D2 :
				 (Sel == 3'd3) ? D3 :
				 (Sel == 3'd4) ? D4 :
				 (Sel == 3'd5) ? D5 :
				 (Sel == 3'd6) ? D6 : D7;
endmodule //Mux_3_8