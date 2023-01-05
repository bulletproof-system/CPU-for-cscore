`timescale 1ns / 1ps
`default_nettype none
`ifdef IVERILOG
`include "control/Controller.v"
`include "datapath/DM.v"
`include "datapath/GRF.v"
`include "datapath/IM.v"
`include "datapath/MUX.v"
`include "datapath/ALU.v"
`include "datapath/Extend.v"
`endif 

module mips(
    input wire clk,
    input wire reset
    );
    wire MemWrite, RegWrite, Zero, ALUSrc;
    wire [1:0] IMControl, RegWAC, RegWDC, Ext;
    wire [4:0] RA1, RA2, GRF_WA, rs, rt, rd;
    wire [5:0] ALUControl;
    wire [15:0] MemAddr, offset;
    wire [31:0] PC, nPC, PC4, Instr, MemWD, MemRD, RD1, RD2, GRF_WD, ALU_D2, ALU_out, imm32;
	  IM InstrMem(.clk(clk), .reset(reset), .PC(PC), .nPC(nPC), .Instr(Instr));
    PC_Calc PC_Calc(.PC(PC), .instr_index(Instr[25:0]), .offset(offset), .Zero(Zero),
                    .RegData(RD1), .IMControl(IMControl), .nPC(nPC), .PC4(PC4));
    DM DataMem(.clk(clk), .reset(reset), .MemWrite(MemWrite),
               .Addr(MemAddr), .WriteData(MemWD), .ReadData(MemRD));
    GRF GRF(.clk(clk), .reset(reset), .RA1(RA1), .RD1(RD1), .RA2(RA2), .RD2(RD2),
            .RegWrite(RegWrite), .WA(GRF_WA), .WD(GRF_WD));
    Controller Controller(.opcode(Instr[31:26]), .funct(Instr[5:0]), .IMControl(IMControl),
                          .RegWAC(RegWAC), .RegWDC(RegWDC), .RegWrite(RegWrite), .MemWrite(MemWrite),
                          .ALUSrc(ALUSrc), .ALUControl(ALUControl), .Ext(Ext));
    ALU ALU(.D1(RD1), .D2(ALU_D2), .op(ALUControl), .Zero(Zero), .out(ALU_out));
    Extend Extend(.imm(offset), .Ext(Ext), .imm32(imm32));
    Mux_RegWAC Mux_RegWAC(.RegWAC(RegWAC), .D1(rd), .D2(rt), .out(GRF_WA));
    Mux_RegWDC Mux_RegWDC(.RegWDC(RegWDC), .D1(ALU_out), .D2(MemRD), .D3(PC4), .out(GRF_WD));
    Mux_ALUSrc Mux_ALUSrc(.ALUSrc(ALUSrc), .D1(RD2), .D2(imm32), .out(ALU_D2));
    

    assign offset = Instr[15:0];
    assign rs = Instr[25:21];
    assign rt = Instr[20:16];
    assign rd = Instr[15:11];
    assign RA1 = rs;
    assign RA2 = rt;
    assign MemAddr = ALU_out;
    assign MemWD = RD2;
    
  always @(posedge clk) begin
    if(reset);
    else begin
        if(RegWrite)
            $display("@%h: $%d <= %h", PC, GRF_WA, GRF_WD);
        if(MemWrite)
            $display("@%h: *%08h <= %h", PC, {16'b0, MemAddr}, MemWD);
    end
  end

endmodule
