`timescale 1ns / 1ps

`ifdef IVERILOG
`include "mips.v"

`endif

module tb;

	// Inputs
	reg clk;
	reg reset;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.clk(clk), 
		.reset(reset)
	);

	initial begin
		// Initialize Inputs
		$dumpfile("wave.vcd");
		$dumpvars();
		clk = 0;
		reset = 1;
		#20 reset = 0;

		#8000 $finish;
	end
    always #15 clk = ~clk; 
endmodule

