`timescale 1ns / 1ps
`default_nettype none
`include "Gobals.v"

// module IM (
// 	input wire clk,
// 	input wire reset,
//     input wire block,
// 	input wire [31:0] nPC,
// 	output wire [31:0] Instr,
// 	output reg [31:0] PC
// );
// 	parameter initaddr = 32'h00003000;
//     reg [31:0] RAM [initaddr : 32'h00006FFF];
// 	assign Instr = RAM[(({PC[15:2],2'b00}-initaddr)>>2)+initaddr];
// 	initial begin
// 		$readmemh("code.txt", RAM, initaddr);
// 	end
// 	always @(posedge clk) begin
//         if(reset)
//             PC <= initaddr;
//         else if(block)
//             PC <= PC;
//         else
//             PC <= nPC;
//     end
// endmodule //IM

module PC_Calc (
	input wire [31:0] PC,
    input wire [25:0] instr_index,
    input wire [15:0] offset,
    input wire block,
    input wire [31:0] D1, D2,
    input wire [2:0] IMControl,
    output wire [31:0] nPC
);
    wire [31:0] PC4, PCB;
    assign PC4 = PC + 32'd4;
    assign PCB = PC + {{14{offset[15]}}, offset, 2'b00};
	assign nPC = block ? PC :
                 (IMControl == `IM_4) ? PC4 :
                 (IMControl == `IM_j) ? {PC[31:28], instr_index, 2'b00} :
                 (IMControl == `IM_jr) ? D1 :
                 (IMControl == `IM_beq) ? (D1 == D2 ? PCB : PC4) :
                 (IMControl == `IM_bne) ? (D1 != D2 ? PCB : PC4) :
                 3'b0;

endmodule //PC_Calc