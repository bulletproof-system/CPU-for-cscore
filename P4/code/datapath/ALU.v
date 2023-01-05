`timescale 1ns / 1ps
`default_nettype none

module ALU(
    input wire [31:0] D1,
    input wire [31:0] D2,
    input wire [5:0]  op,
    output wire Zero,
    output wire [31:0] out
    );
    assign out = (op == 6'b100000) ? D1 + D2 : // add
                 (op == 6'b100010) ? D1 - D2 : // sub
                 (op == 6'b100101) ? D1 | D2 : // or
                 32'b0;
    assign Zero = (out == 32'b0);
endmodule
