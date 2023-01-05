`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:02:03 12/04/2022
// Design Name:   fpga_top
// Module Name:   D:/LTT/repository/cscore/CPU/P8/code/tb/tb_calc.v
// Project Name:  P8
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: fpga_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_calc;

	// Inputs
	reg clk_in;
	reg sys_rstn;
	reg [7:0] dip_switch0;
	reg [7:0] dip_switch1;
	reg [7:0] dip_switch2;
	reg [7:0] dip_switch3;
	reg [7:0] dip_switch4;
	reg [7:0] dip_switch5;
	reg [7:0] dip_switch6;
	reg [7:0] dip_switch7;
	reg [7:0] user_key; 
	reg uart_rxd;

	// Outputs
	wire [31:0] led_light;
	wire [7:0] digital_tube2;
	wire digital_tube_sel2;
	wire [7:0] digital_tube1;
	wire [3:0] digital_tube_sel1;
	wire [7:0] digital_tube0;
	wire [3:0] digital_tube_sel0;
	wire uart_txd;

	// Instantiate the Unit Under Test (UUT)
	fpga_top uut (
		.clk_in(clk_in), 
		.sys_rstn(sys_rstn), 
		.dip_switch0(dip_switch0), 
		.dip_switch1(dip_switch1), 
		.dip_switch2(dip_switch2), 
		.dip_switch3(dip_switch3), 
		.dip_switch4(dip_switch4), 
		.dip_switch5(dip_switch5), 
		.dip_switch6(dip_switch6), 
		.dip_switch7(dip_switch7), 
		.user_key(user_key), 
		.led_light(led_light), 
		.digital_tube2(digital_tube2), 
		.digital_tube_sel2(digital_tube_sel2), 
		.digital_tube1(digital_tube1), 
		.digital_tube_sel1(digital_tube_sel1), 
		.digital_tube0(digital_tube0), 
		.digital_tube_sel0(digital_tube_sel0), 
		.uart_rxd(uart_rxd), 
		.uart_txd(uart_txd)
	);

	initial begin
		// Initialize Inputs
		clk_in = 0;
		sys_rstn = 0;
		{dip_switch3, dip_switch2, dip_switch1, dip_switch0} = ~32'h0;
		{dip_switch7, dip_switch6, dip_switch5, dip_switch4} = ~32'h8fce_1234;
		user_key = 8'b1111_1001;
		uart_rxd = 1'b0;

		// Wait 100 ns for global reset to finish
		#30;
        sys_rstn = 1;
	end
    
	always #20 clk_in = ~clk_in;
endmodule

