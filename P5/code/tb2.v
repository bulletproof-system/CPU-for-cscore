`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:51:15 11/06/2022
// Design Name:   mips
// Module Name:   D:/LTT/repository/cscore/CPU/PipeLine-CPU/code/tb2.v
// Project Name:  PipeLine-CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mips
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb2;

	// Inputs
	reg clk;
	reg reset;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.clk(clk), 
		.reset(reset)
	);

	initial begin
		//$wave.vcd");
		//$dumpvars();dumpfile("
		clk = 0;
		reset = 1;
		#15 reset = 0;


		#8000 $finish;
	end
	always #10 clk = ~clk;
      
endmodule

