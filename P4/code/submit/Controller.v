`timescale 1ns / 1ps
`default_nettype none

module Controller(
    input wire [5:0] opcode,
    input wire [5:0] funct,
    output wire [1:0] IMControl,
    output wire [1:0] RegWAC,
    output wire [1:0] RegWDC,
    output wire RegWrite,
    output wire MemWrite,
    output wire ALUSrc,
    output wire [5:0] ALUControl,
    output wire [1:0] Ext
    );
    wire add, sub, ori, lw, sw, beq, lui, j, jal, jr;
    assign add = (opcode == 6'b0 && funct == 6'b100000);
    assign sub = (opcode == 6'b0 && funct == 6'b100010);
    assign ori = (opcode == 6'b001101);
    assign lw  = (opcode == 6'b100011);
    assign sw  = (opcode == 6'b101011);
    assign beq = (opcode == 6'b000100);
    assign lui = (opcode == 6'b001111);
    assign j   = (opcode == 6'b000010);
    assign jal = (opcode == 6'b000011);
    assign jr  = (opcode == 6'b0 && funct == 6'b001000);

    assign IMControl = (add || sub || ori || lw || sw || lui) ? 2'b00 : // PC + 4
                       (j || jal) ? 2'b01 : 
                       jr ? 2'b10 : 2'b11;
    assign RegWAC = (add || sub) ? 2'b00 : // Instr[15:11]
                    (ori || lw || lui)  ? 2'b01 : // Instr[20:16]
                    2'b10; // jal 11111
    assign RegWDC = (add || sub || ori || lui) ? 2'b00 : // ALU:out
                    (lw) ? 2'b01 : // DM:RD
                    2'b10; // PC_Calc:PC4
    assign RegWrite = (add || sub || ori || lw || lui || jal);
    assign MemWrite = sw;
    assign ALUSrc = (ori || lw || sw || lui);
    assign ALUControl = add ? 6'b100000 :
                        sub ? 6'b100010 :
                        ori ? 6'b100101 :
                        lw  ? 6'b100000 : 
                        sw  ? 6'b100000 : 
                        beq ? 6'b100010 :
                        lui ? 6'b100101 :
                        j   ? 6'b000000 :
                        jal ? 6'b000000 :
                        jr  ? 6'b000000 : 6'b000000;
    assign Ext = ori ? 2'b00 : // zero_ext
                 lw  ? 2'b01 : // sign_ext
                 sw  ? 2'b01 : // sign_ext
                 lui ? 2'b10 : // lui
                 2'b00; 
endmodule
