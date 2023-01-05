`timescale 1ns / 1ps
`default_nettype none

module IM(
    input wire clk,
    input wire reset,
    input wire [31:0] nPC,
    output reg [31:0] PC,
    output wire [31:0] Instr
    );
    parameter initaddr = 32'h00003000;
    reg [31:0] RAM [initaddr : 32'h00006FFF];
    // wire word = {RAM[{PC[15:2], 2'b00}], RAM[{PC[15:2], 2'b01}], RAM[{PC[15:2], 2'b10}], RAM[{PC[15:2], 2'b11}]};
    assign Instr = RAM[(({PC[15:2],2'b00}-initaddr)>>2)+initaddr];
    initial begin
        $readmemh("code.txt", RAM, initaddr);
    end
    always @(posedge clk) begin
        if(reset)
            PC <= initaddr;
        else begin
            PC <= nPC;
        end
    end
endmodule

module PC_Calc(
    input wire [31:0] PC,
    input wire [25:0] instr_index,
    input wire [15:0] offset,
    input wire Zero,
    input wire [31:0] RegData,
    input wire [1:0] IMControl,
    output wire [31:0] nPC,
    output wire [31:0] PC4
    );
    assign nPC = (IMControl == 2'b00) ? PC + 32'd4 : // PC + 4
                 (IMControl == 2'b01) ? {PC[31:28], instr_index, 2'b00} : // j or jal
                 (IMControl == 2'b10) ? RegData : // jr
                 (Zero == 1'b1) ? PC + 32'd4 + {{14{offset[15]}}, offset, 2'b00} : PC + 32'd4; // beq false
    assign PC4 = PC + 32'd4;
endmodule