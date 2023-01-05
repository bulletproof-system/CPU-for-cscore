`timescale 1ns / 1ps
`default_nettype none

module DM(
    input wire clk,
    input wire reset,
    input wire MemWrite,
    input wire [15:0] Addr,
    input wire [31:0] WriteData,
    output wire [31:0] ReadData
    );
    integer i;
    reg [31:0] mem [0:32'h2FFF];
    // wire [31:0] word = {mem[{Addr[15:2], 2'b00}], mem[{Addr[15:2], 2'b01}], mem[{Addr[15:2], 2'b10}], mem[{Addr[15:2], 2'b11}]};
    assign ReadData = mem[Addr[15:2]];
    always @(posedge clk) begin
        if (reset) begin
            for(i=0;i<32'h3000;i=i+1) mem[i] <= 32'b0;
        end else begin
            if(MemWrite)
                mem[Addr[15:2]] <= WriteData;
            else;
        end
    end

endmodule
