`timescale 1ns / 1ps
`default_nettype none
`include "Gobals.v"

// module DM(
//     input wire clk,
//     input wire reset,
//     input wire MemWrite,
//     input wire [31:0] Addr,
//     input wire [31:0] WriteData,
//     output wire [31:0] ReadData
//     );
//     integer i;
//     reg [31:0] mem [0:32'h2FFF];
//     assign ReadData = mem[Addr[31:2]];
//     always @(posedge clk) begin
//         if (reset) begin
//             for(i=0;i<32'h3000;i=i+1) mem[i] <= 32'b0;
//         end else begin
//             if(MemWrite)
//                 mem[Addr[31:2]] <= WriteData;
//             else;
//         end
//     end

// endmodule
module BE (
    input wire [1:0] A,
    input wire [31:0] Din, WriteData,
    input wire [2:0] Op,
    output wire [3:0] m_data_byteen,
    output wire [31:0] Dout, m_data_wdata
);
    assign m_data_byteen = (Op == `BE_sw) ? 4'b1111 :
                           (Op == `BE_sh) ? (A[1]==1'b0 ? 4'b0011 : 4'b1100) :
                           (Op == `BE_sb) ? ((A == 2'b00) ? 4'b0001 :
                                             (A == 2'b01) ? 4'b0010 :
                                             (A == 2'b10) ? 4'b0100 : 4'b1000) : 4'b0000;
    assign m_data_wdata  = (Op == `BE_sw) ? WriteData :
                           (Op == `BE_sh) ? (A[1]==1'b0 ? {16'b0, WriteData[15:0]} : {WriteData[15:0], 16'b0}) :
                           (Op == `BE_sb) ? ((A == 2'b00) ? {24'b0, WriteData[7:0]} :
                                             (A == 2'b01) ? {16'b0, WriteData[7:0], 8'b0} :
                                             (A == 2'b10) ? {8'b0, WriteData[7:0], 16'b0} : {WriteData[7:0], 24'b0}) : 32'd0;
    assign Dout = (Op == `BE_lw)  ? Din : 
                  (Op == `BE_lb)  ? ((A == 2'b00) ? {{24{Din[ 7]}}, Din[7:0]} : 
                                    (A == 2'b01) ? {{24{Din[15]}}, Din[15:8]} : 
                                    (A == 2'b10) ? {{24{Din[23]}}, Din[23:16]} : {{24{Din[31]}}, Din[31:24]}) :
                  (Op == `BE_lbu) ? ((A == 2'b00) ? {24'b0, Din[7:0]} : 
                                    (A == 2'b01) ? {24'b0, Din[15:8]} : 
                                    (A == 2'b10) ? {24'b0, Din[23:16]} : {24'b0, Din[31:24]}) :
                  (Op == `BE_lh)  ? (A[1]==1'b0 ? {{16{Din[15]}}, Din[15:0]} : {{16{Din[31]}}, Din[31:16]}) : 
                  (Op == `BE_lhu) ? (A[1]==1'b0 ? {16'b0, Din[15:0]} : {16'b0, Din[31:16]}) : 32'b0;
endmodule //BE