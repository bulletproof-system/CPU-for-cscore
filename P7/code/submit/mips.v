`timescale 1ns / 1ps
`default_nettype none
`include "Gobals.v"
`ifdef IVERILOG
`include "Controller.v"
`include "IM.v"
`include "GRF.v"
`include "ALU.v"
`include "Mux.v"
`include "Bridge.v"
`include "P7_standard_timer_2019.v"
`endif

module mips(
    input wire clk,
    input wire reset, 
    input wire interrupt, // 外部中断信号
    output wire [31:0] i_inst_addr,
    input wire [31:0] i_inst_rdata,

    output wire [31:0] m_data_addr,
    input wire [31:0] m_data_rdata,
    output wire [31:0] m_data_wdata,
    output wire [3:0] m_data_byteen,
    output wire [31:0] m_inst_addr,

    output wire w_grf_we,
    output wire [4:0] w_grf_addr,
    output wire [31:0] w_grf_wdata,
    output wire [31:0] w_inst_addr,

    output wire [31:0] macroscopic_pc, // 宏观 PC
    output wire [31:0] m_int_addr,     // 中断发生器待写入地址
    output wire [3 :0] m_int_byteen   // 中断发生器字节使能信号
);
    reg [31:0] F_PC;
    always @(posedge clk) begin
        if(reset) 
            F_PC <= 32'h00003000;
        else
            F_PC <= F_nPC;
    end
//====================================IF====================================//
    wire F_BD;
    wire [2:0] IMControl;
    wire [4:0] F_ExcCodeOut;
    wire [31:0] F_nPC, F_Instr;
    assign i_inst_addr = F_PC;
    assign F_Instr = (F_ExcCodeOut == `Int) ? i_inst_rdata : 32'd0;
    assign F_ExcCodeOut = (F_PC[1:0] != 2'b0) ? `AdEL : 
                          (F_PC < 32'h0000_3000) ? `AdEL :
                          (32'h0000_6fff < F_PC) ? `AdEL : `Int;
    PC_Calc PC_Calc(.PC(F_PC), .instr_index(D_instr_index), .offset(D_offset),
                    .block(block),
                    .D1(D_D1), .D2(D_D2),
                    .IMControl(IMControl), .nPC(F_nPC),
                    .eret(eret), .Req(Req), .EPC(EPCOut));
//====================================IF====================================//
    reg D_BD;
    reg [4:0] D_ExcCodeIn;
    reg [31:0] D_Instr, D_PC;
    always @(posedge clk) begin
        if(reset || Req) begin
            D_BD <= 0;
            D_Instr <= 0;
            D_PC <= 0;
            D_ExcCodeIn <= 0;
        end else if(block) begin
            D_BD <= D_BD;
            D_Instr <= D_Instr;
            D_PC <= D_PC;
            D_ExcCodeIn <= D_ExcCodeIn;
        end else if(eret) begin
            D_BD <= 1'b0;
            D_Instr <= 32'd0;
            D_PC <= F_nPC;
            D_ExcCodeIn <= `Int;
        end else begin
            D_BD <= F_BD;
            D_Instr <= F_Instr;
            D_PC <= F_PC;
            D_ExcCodeIn <= F_ExcCodeOut;
        end
    end
//====================================ID====================================//
    wire D_Beq, D_ALUSrc, D_Ext, D_RegWrite,D_link, D_lui,D_start, eret, D_CP0Write, D_eret, D_EPCWrite;
    wire [1:0] D_WA_Sel, D_RagData_Sel, D_ALUData_Sel;
    wire [2:0] D_rs_T_use, D_rt_T_use, D_T_new, D_MDop;
    wire [3:0] D_Instr_type, D_BEop;
    wire [4:0] D_rs, D_rt, D_rd, D_RegWA, D_rs_Addr, D_rt_Addr, D_ExcCodeOut, D_CP0Addr;
    wire [5:0] D_ALUop;
    wire [15:0] D_offset, D_Imm;
    wire [25:0] D_instr_index;
    wire [31:0] D_RD1, D_RD2, D_D1, D_D2;
    assign D_Beq = (D_D1 == D_D2);
    assign D_rs = D_Instr[25:21];
    assign D_rt = D_Instr[20:16];
    assign D_rd = D_Instr[15:11];
    assign D_offset = D_Instr[15:0];
    assign D_Imm    = D_Instr[15:0];
    assign D_instr_index = D_Instr[25:0];
    // output
    assign w_grf_we = W_RegWrite;
    assign w_grf_addr = W_RegWA;
    assign w_grf_wdata = W_RegWD;
    assign w_inst_addr = W_PC;
    
    assign D_eret = eret;
    assign D_CP0Addr = D_rd;

    Controller Ctrl(.instr(D_Instr), .ExcCodeIn(D_ExcCodeIn),
                    .IMControl(IMControl), .WA_Sel(D_WA_Sel), .ALUData_Sel(D_ALUData_Sel),
                    .ALUSrc(D_ALUSrc), .Ext(D_Ext),
                    .RegWrite(D_RegWrite), .start(D_start), 
                    .MDop(D_MDop), .BEop(D_BEop), 
                    .ALUop(D_ALUop), .RegData_Sel(D_RagData_Sel),
                    .rs_Addr(D_rs_Addr), .rt_Addr(D_rt_Addr), 
                    .T_new(D_T_new), .rs_T_use(D_rs_T_use), .rt_T_use(D_rt_T_use),
                    .CP0Write(D_CP0Write), .Instr_type(D_Instr_type), .ExcCodeOut(D_ExcCodeOut), 
                    .eret(eret), .BD(F_BD), .EPCWrite(D_EPCWrite)
                    );

    GRF GRF(.clk(clk), .reset(reset), .RA1(D_rs), .RA2(D_rt), .RegWrite(W_RegWrite), 
            .WA(W_RegWA), .WD(W_RegWD), .RD1(D_RD1), .RD2(D_RD2));
    Mux_2_4_5bit WA_Mux(.Sel(D_WA_Sel), .D0(D_rd), .D1(D_rt), .D2(5'h1f), .out(D_RegWA));

    Mux_2_4 D_D1_Mux(.Sel(D_D1_Sel), .D0(D_RD1), .D1(M_ALU_out), .D2(FW_lui), .D3(E_PC+32'd8), .out(D_D1));
    Mux_2_4 D_D2_Mux(.Sel(D_D2_Sel), .D0(D_RD2), .D1(M_ALU_out), .D2(FW_lui), .D3(E_PC+32'd8), .out(D_D2));

//====================================ID====================================//
    reg E_ALUSrc, E_Ext, E_RegWrite, E_link, E_lui, E_start, E_BD, E_CP0Write, E_eret, E_EPCWrite;
    reg [1:0] E_RegData_Sel, E_ALUData_Sel;
    reg [2:0] E_T_new, E_MDop;
    reg [3:0] E_BEop, E_Instr_type;
    reg [4:0] E_RegWA, E_ExcCodeIn, E_CP0Addr;
    reg [5:0] E_ALUop;
    reg [15:0] E_Imm;
    reg [31:0] E_PC, E_I1, E_I2;
    always @(posedge clk) begin 
        if(reset || Req) begin
            E_ALUSrc    <= 1'b0;
            E_Ext       <= 1'b0;
            E_RegWrite  <= 1'b0;
            E_link      <= 1'b0;
            E_lui       <= 1'b0;
            E_start     <= 1'b0;
            E_BD        <= 1'b0;
            E_CP0Write  <= 1'b0;
            E_eret      <= 1'b0;
            E_EPCWrite  <= 1'b0;
            E_RegData_Sel <= 2'b0;
            E_ALUData_Sel <= 2'b0;
            E_T_new     <= 3'b0;
            E_MDop      <= 3'b0;
            E_BEop      <= 4'b0;
            E_Instr_type<= 4'b0;
            E_RegWA     <= 5'b0;
            E_ExcCodeIn <= 5'b0;
            E_CP0Addr <= 5'b0;
            E_ALUop     <= 6'b0;
            E_Imm       <= 16'b0;
            E_PC        <= 32'b0;
            E_I1        <= 32'b0;
            E_I2        <= 32'b0;
        end else if(block) begin
            E_ALUSrc    <= 1'b0;
            E_Ext       <= 1'b0;
            E_RegWrite  <= 1'b0;
            E_link      <= 1'b0;
            E_lui       <= 1'b0;
            E_start     <= 1'b0;
            E_BD        <= D_BD;
            E_CP0Write  <= 1'b0;
            E_eret      <= 1'b0;
            E_EPCWrite  <= 1'b0;
            E_RegData_Sel <= 2'b0;
            E_ALUData_Sel <= 2'b0;
            E_T_new     <= 3'b0;
            E_MDop      <= 3'b0;
            E_BEop      <= 4'b0;
            E_Instr_type<= 4'b0;
            E_RegWA     <= 5'b0;
            E_ExcCodeIn <= 5'b0;
            E_CP0Addr <= 5'b0;
            E_ALUop     <= 6'b0;
            E_Imm       <= 16'b0;
            E_PC        <= D_PC;
            E_I1        <= 32'b0;
            E_I2        <= 32'b0;
        end else begin
            E_ALUSrc    <= D_ALUSrc;
            E_Ext       <= D_Ext;
            E_RegWrite  <= D_RegWrite;
            E_link      <= D_link;
            E_lui       <= D_lui;
            E_start     <= D_start;
            E_BD        <= D_BD;
            E_CP0Write  <= D_CP0Write;
            E_eret      <= D_eret;
            E_EPCWrite  <= D_EPCWrite;
            E_RegData_Sel <= D_RagData_Sel;
            E_ALUData_Sel <= D_ALUData_Sel;
            E_T_new     <= (D_T_new == 3'd0) ? 3'd0 : D_T_new - 3'd1;
            E_BEop      <= D_BEop;
            E_MDop      <= D_MDop;
            E_Instr_type<= D_Instr_type;
            E_RegWA     <= D_RegWA;
            E_ExcCodeIn <= D_ExcCodeOut;
            E_CP0Addr   <= D_CP0Addr;
            E_ALUop     <= D_ALUop;
            E_Imm       <= D_Imm;
            E_PC        <= D_PC;
            E_I1        <= D_D1;
            E_I2        <= D_D2;
        end
    end
//====================================EX====================================//
    wire E_busy;
    wire [4:0] E_ExcCodeOut;
    wire [31:0] E_ALU_out, E_D1, E_D2, FW_lui, E_out, E_LO, E_HI;

    assign FW_lui = {E_Imm, 16'b0};

    Mux_2_4 E_D1_Mux(.Sel(E_D1_Sel), .D0(E_I1), .D1(M_ALU_out), .D2(W_RegWD), .out(E_D1));
    Mux_2_4 E_D2_Mux(.Sel(E_D2_Sel), .D0(E_I2), .D1(M_ALU_out), .D2(W_RegWD), .out(E_D2));

    ALU ALU(.D1(E_D1), .D2(E_D2), .Imm(E_Imm), .ALUop(E_ALUop), .ALUSrc(E_ALUSrc), 
            .Ext(E_Ext), .Instr_type(E_Instr_type), .ExcCodeIn(E_ExcCodeIn),
            .out(E_ALU_out), .ExcCodeOut(E_ExcCodeOut));
    multiply_divide MD(.clk(clk), .reset(reset), .start(E_start),
            .Op(E_MDop), .D1(E_D1), .D2(E_D2), .Req(Req),
            .busy(E_busy), 
            .LO(E_LO), .HI(E_HI));

    Mux_2_4 ALUData_Mux(.Sel(E_ALUData_Sel), .D0(E_ALU_out), .D1(E_PC+32'd8), .D2(E_LO), .D3(E_HI), .out(E_out));
//====================================EX====================================//
    reg M_RegWrite, M_CP0Write, M_BD, M_eret;
    reg [1:0] M_RegData_Sel;
    reg [2:0] M_T_new;
    reg [3:0] M_BEop, M_Instr_type;
    reg [4:0] M_RegWA, M_ExcCodeIn, M_CP0Addr;
    reg [31:0] M_PC, M_ALU_out, M_D2;
    always @(posedge clk) begin
        if(reset || Req) begin
            M_RegWrite  <= 1'b0;
            M_CP0Write  <= 1'b0;
            M_BD        <= 1'b0;
            M_eret      <= 1'b0;
            M_RegData_Sel <= 2'b0;
            M_T_new     <= 3'b0;
            M_BEop      <= 4'b0;
            M_Instr_type<= 4'b0;
            M_RegWA     <= 5'b0;
            M_ExcCodeIn <= 5'b0;
            M_CP0Addr    <= 5'b0;
            M_PC        <= 32'b0;
            M_ALU_out   <= 32'b0;
            M_D2        <= 32'b0;
        end else begin
            M_RegWrite  <= E_RegWrite;
            M_CP0Write  <= E_CP0Write;
            M_BD        <= E_BD;
            M_eret      <= E_eret;
            M_RegData_Sel <= E_RegData_Sel;
            M_T_new     <= (E_T_new == 3'd0) ? E_T_new : E_T_new - 3'd1;
            M_BEop      <= E_BEop;
            M_Instr_type<= E_Instr_type;
            M_RegWA     <= E_RegWA;
            M_ExcCodeIn <= E_ExcCodeOut;
            M_CP0Addr   <= E_CP0Addr;
            M_PC        <= E_PC;
            M_ALU_out   <= E_out;
            M_D2        <= E_D2;
        end
    end
//====================================Mem===================================//
    wire Req, IRQ_T1, IRQ_T0, WE_T0, WE_T1, Interrupt_enable;
    wire [4:0] M_ExcCodeOut;
    wire [31:2] Addr_T0, Addr_T1;
    wire [31:0] M_MemRD, M_WriteData, EPCOut, M_CP0Out, Dout_T0, Dout_T1, Din_T0, Din_T1;

    assign macroscopic_pc = M_PC;
    assign m_inst_addr = M_PC;

    Mux_1_2 WriteData_Mux(.Sel(WriteData_Sel), .D0(M_D2), .D1(W_RegWD), .out(M_WriteData));
    
    CP0 CP0(.clk(clk), .reset(reset), .en(M_CP0Write), .Addr(M_CP0Addr), .CP0In(M_WriteData),
            .VPC(M_PC), .BDIn(M_BD), .ExcCodeIn(M_ExcCodeOut), .HWIn({3'b0, interrupt, IRQ_T1, IRQ_T0}),
            .EXLClr(M_eret), .CP0Out(M_CP0Out), .EPCOut(EPCOut), .Req(Req));

    Bridge Bridge(.Addr(M_ALU_out), .WriteData(M_WriteData), .ExcCodeIn(M_ExcCodeIn), .Op(M_BEop), 
                  .m_data_rdata(m_data_rdata), .Dout_T0(Dout_T0), .Dout_T1(Dout_T1), .ReadData(M_MemRD),
                  .m_data_addr(m_data_addr), .m_data_wdata(m_data_wdata), .m_data_byteen(m_data_byteen),
                  .Addr_T0(Addr_T0), .WE_T0(WE_T0), .Din_T0(Din_T0),
                  .Addr_T1(Addr_T1), .WE_T1(WE_T1), .Din_T1(Din_T1),
                  .m_int_addr(m_int_addr), .m_int_byteen(m_int_byteen),
                  .ExcCodeOut(M_ExcCodeOut), .Req(Req));
    
    TC T0(.clk(clk), .reset(reset), .Addr(Addr_T0), .WE(WE_T0), .Din(Din_T0), .Dout(Dout_T0), .IRQ(IRQ_T0));
    TC T1(.clk(clk), .reset(reset), .Addr(Addr_T1), .WE(WE_T1), .Din(Din_T1), .Dout(Dout_T1), .IRQ(IRQ_T1));

//====================================Mem===================================//
    reg W_RegWrite;
    reg[1:0] W_RegData_Sel;
    reg [3:0] W_Instr_type;
    reg [4:0] W_RegWA;
    reg [31:0] W_PC, W_ALU_out, W_MemRD, W_CP0Out;
    always @(posedge clk) begin
        if(reset || Req) begin
            W_RegWrite  <= 1'b0;
            W_RegData_Sel <= 2'b0;
            W_Instr_type<= 4'b0;
            W_RegWA     <= 5'b0;
            W_PC        <= 32'b0;
            W_ALU_out   <= 32'b0;
            W_MemRD     <= 32'b0;
            W_CP0Out    <= 32'b0;
        end else begin
            W_RegWrite  <= M_RegWrite;
            W_RegData_Sel <= M_RegData_Sel;
            W_Instr_type<= M_Instr_type;
            W_RegWA     <= M_RegWA;
            W_PC        <= M_PC;
            W_ALU_out   <= M_ALU_out;
            // W_ALU_out   <= (M_PC == 32'h3018) ? temp : M_ALU_out;
            W_MemRD     <= M_MemRD;
            W_CP0Out    <= M_CP0Out;
        end
    end
//====================================WB====================================//
    
    wire [31:0] W_RegWD;

    Mux_2_4 RegData_Mux(.Sel(W_RegData_Sel), .D0(W_ALU_out), .D1(W_MemRD), .D2(W_CP0Out), .out(W_RegWD));
    

//====================================Hazard================================//
    wire block, WriteData_Sel;
    wire [1:0] D_D1_Sel, D_D2_Sel, E_D1_Sel, E_D2_Sel;
    Hazard_Controller Hazard(.clk(clk), .reset(reset), 
                             .D_Instr_type(D_Instr_type),
                             .D_rs_Addr(D_rs_Addr), .D_rs_T_use(D_rs_T_use),
                             .D_rt_Addr(D_rt_Addr), .D_rt_T_use(D_rt_T_use), 
                             .E_RegWA(E_RegWA), .E_T_new(E_T_new), 
                             .E_RegWrite(E_RegWrite), .E_busy(E_busy), .E_Instr_type(E_Instr_type),
                             .M_RegWA(M_RegWA), .M_T_new(M_T_new),
                             .M_RegWrite(M_RegWrite), .M_Instr_type(M_Instr_type),
                             .W_RegWrite(W_RegWrite), .W_Instr_type(W_Instr_type),
                             .D_D1_Sel(D_D1_Sel), .D_D2_Sel(D_D2_Sel),
                             .E_D1_Sel(E_D1_Sel), .E_D2_Sel(E_D2_Sel),
                             .block(block), .WriteData_Sel(WriteData_Sel),
                             .eret(D_eret), .E_EPCWrite(E_EPCWrite)
                            );

//====================================output================================//
    // always @(posedge clk) begin
    //     if(reset) ;
    //     else begin
    //         if(W_RegWrite)
    //             $display("%d@%08h: $%2d <= %08h", $time, W_PC, W_RegWA, W_RegWD);
    //         else;
    //         if(M_MemWrite)
    //             $display("%d@%08h: *%08h <= %08h", $time, M_PC, M_MemAddr, M_WriteData);
    //         else;
    //     end

    // end

endmodule


    