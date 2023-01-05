`timescale 1ns / 1ps
`default_nettype none
`include "Gobals.v"

module Bridge(
	input wire clk, reset,
	input wire [31:0] Addr,
	input wire [31:0] WriteData,
	input wire [4:0] ExcCodeIn,
	input wire [3:0] Op,
	input wire Req,
	output wire [4:0] ExcCodeOut,
	output wire [31:0] ReadData,

	output wire [31:0] m_data_addr,
	input wire [31:0] m_data_rdata,
	output wire [31:0] m_data_wdata,
	output wire [3:0] m_data_byteen,

	output wire [31:2] Addr_T0,
	output wire WE_T0,
	output wire [31:0] Din_T0,
	input wire [31:0] Dout_T0,

	input wire [31:0] dip_switch_3_0, dip_switch_7_4,

	input wire [7:0] user_key,

	output wire [3:0] led_byteen,
	output wire [31:0] led_wdata,

	output wire tube_addr, 
	output wire [3:0] tube_byteen,
	output wire [31:0] tube_wdata,

	output wire uart_we, uart_load,
	output wire [1:0] uart_addr,
	output wire [31:0] uart_wdata, 
	input wire [31:0] uart_rdata
);
	wire Load, Store;
	wire [2:0] device;
	wire [31:0] Dout_DM, Dout_DIP, Dout_KEY, Dout_UART;
	assign Load = (Op == `BE_lw || Op == `BE_lh || Op == `BE_lhu || Op == `BE_lb || Op == `BE_lbu);
	assign Store = (Op == `BE_sw || Op == `BE_sh || Op == `BE_sb);
	assign device = (32'h0000_0000 <= Addr && Addr <= 32'h0000_2fff) ? `device_DM :
					(32'h0000_7f00 <= Addr && Addr <= 32'h0000_7f0b) ? `device_T0 : 
					(32'h0000_7f30 <= Addr && Addr <= 32'h0000_7f3f) ? `device_UART :
					(32'h0000_7f50 <= Addr && Addr <= 32'h0000_7f57) ? `device_TUBE : 
					(32'h0000_7f60 <= Addr && Addr <= 32'h0000_7f67) ? `device_DIP : 
					(32'h0000_7f68 <= Addr && Addr <= 32'h0000_7f6b) ? `device_KEY : 
					(32'h0000_7f70 <= Addr && Addr <= 32'h0000_7f73) ? `device_LED : 
					`device_undefine;
	assign ExcCodeOut = (ExcCodeIn != 5'd0) ? ExcCodeIn : 
						(Op == `BE_lw && Addr[1:0] != 2'b00) ? `AdEL : 
						((Op == `BE_lh || Op == `BE_lhu) && Addr[0] != 1'b0) ? `AdEL : 
						((Op == `BE_lh || Op == `BE_lhu || Op == `BE_lb || Op == `BE_lbu) && device == `device_T0) ? `AdEL :
						(Load && (device == `device_undefine)) ? `AdEL :
						(Op == `BE_sw && Addr[1:0] != 2'b00) ? `AdES :
						(Op == `BE_sh && Addr[0] != 1'b0) ? `AdES :
						((Op == `BE_sh || Op == `BE_sb) && device == `device_T0) ? `AdES :
						(Store && device == `device_T0 && Addr[3:2] == 2'b10) ? `AdES :
						(Store && (device == `device_undefine)) ? `AdES : `Int;
	// DM
	assign m_data_addr = Addr;
	assign m_data_wdata = (Op == `BE_sw) ? WriteData :
                          (Op == `BE_sh) ? (Addr[1]==1'b0 ? {16'b0, WriteData[15:0]} : {WriteData[15:0], 16'b0}) :
                          (Op == `BE_sb) ? ((Addr[1:0] == 2'b00) ? {24'b0, WriteData[7:0]} :
                                            (Addr[1:0] == 2'b01) ? {16'b0, WriteData[7:0], 8'b0} :
                                            (Addr[1:0] == 2'b10) ? {8'b0, WriteData[7:0], 16'b0} : {WriteData[7:0], 24'b0}) : 32'd0;
	assign m_data_byteen = 	(Req) ? 4'b0000 :
							(device != `device_DM) ? 4'b0000 :
							(Op == `BE_sw) ? 4'b1111 :
							(Op == `BE_sh) ? (Addr[1] == 1'b0 ? 4'b0011 : 4'b1100) :
							(Op == `BE_sb) ? ((Addr[1:0] == 2'b00) ? 4'b0001 :
											(Addr[1:0] == 2'b01) ? 4'b0010 :
											(Addr[1:0] == 2'b10) ? 4'b0100 : 4'b1000) : 
											4'b0000;				
	assign Dout_DM = (Op == `BE_lw)  ? m_data_rdata : 
					(Op == `BE_lb)  ? ((Addr[1:0] == 2'b00) ? {{24{m_data_rdata[ 7]}}, m_data_rdata[7:0]} : 
										(Addr[1:0] == 2'b01) ? {{24{m_data_rdata[15]}}, m_data_rdata[15:8]} : 
										(Addr[1:0] == 2'b10) ? {{24{m_data_rdata[23]}}, m_data_rdata[23:16]} : {{24{m_data_rdata[31]}}, m_data_rdata[31:24]}) :
					(Op == `BE_lbu) ? ((Addr[1:0] == 2'b00) ? {24'b0, m_data_rdata[7:0]} : 
										(Addr[1:0] == 2'b01) ? {24'b0, m_data_rdata[15:8]} : 
										(Addr[1:0] == 2'b10) ? {24'b0, m_data_rdata[23:16]} : {24'b0, m_data_rdata[31:24]}) :
					(Op == `BE_lh)  ? (Addr[1]==1'b0 ? {{16{m_data_rdata[15]}}, m_data_rdata[15:0]} : {{16{m_data_rdata[31]}}, m_data_rdata[31:16]}) : 
					(Op == `BE_lhu) ? (Addr[1]==1'b0 ? {16'b0, m_data_rdata[15:0]} : {16'b0, m_data_rdata[31:16]}) : 32'b0;;
	// T0
	assign Addr_T0 = Addr[31:2];
	assign WE_T0 = (!Req && device == `device_T0 && Op == `BE_sw) ? 1'b1 : 1'b0;
	assign Din_T0 = WriteData;

	// UART
	assign uart_we = (!Req && device == `device_UART && Op == `BE_sw);
	assign uart_load = (!Req && device == `device_UART && Op == `BE_lw);
	assign uart_addr = Addr[3:2];
	assign uart_wdata = WriteData;
	assign Dout_UART = uart_rdata;

	// KEY
	assign Dout_KEY = {24'b0, user_key};
	// DIP
	assign Dout_DIP = Addr[2] ? dip_switch_7_4 : dip_switch_3_0;

	reg [2:0] last_device;
	reg [31:0] ReadData_reg;

	always @(posedge clk) begin
		last_device <= device;
		if(reset || Req)
			ReadData_reg <= 32'd0;
		else if(device == `device_T0)
			ReadData_reg <= Dout_T0;
		else if(device == `device_UART)
			ReadData_reg <= Dout_UART;
		else if(device == `device_KEY)
			ReadData_reg <= Dout_KEY;
		else if(device == `device_DIP)
			ReadData_reg <= Dout_DIP;
		else
			ReadData_reg <= 32'd0;
	end
	assign ReadData = (last_device == `device_DM) ? Dout_DM : ReadData_reg;

	// LED
	assign led_byteen = (Req) ? 4'b0000 :
						(device != `device_LED) ? 4'b0000 :
						(Op == `BE_sw) ? 4'b1111 :
						(Op == `BE_sh) ? (Addr[1] == 1'b0 ? 4'b0011 : 4'b1100) :
						(Op == `BE_sb) ? ((Addr[1:0] == 2'b00) ? 4'b0001 :
										(Addr[1:0] == 2'b01) ? 4'b0010 :
										(Addr[1:0] == 2'b10) ? 4'b0100 : 4'b1000) : 
										4'b0000;
	assign led_wdata =  (Op == `BE_sw) ? WriteData :
						(Op == `BE_sh) ? (Addr[1]==1'b0 ? {16'b0, WriteData[15:0]} : {WriteData[15:0], 16'b0}) :
						(Op == `BE_sb) ? ((Addr[1:0] == 2'b00) ? {24'b0, WriteData[7:0]} :
										(Addr[1:0] == 2'b01) ? {16'b0, WriteData[7:0], 8'b0} :
										(Addr[1:0] == 2'b10) ? {8'b0, WriteData[7:0], 16'b0} : {WriteData[7:0], 24'b0}) : 32'd0;

	// TUBE
	assign tube_addr = Addr[2];
	assign tube_byteen = (Req) ? 4'b0000 :
						(device != `device_TUBE) ? 4'b0000 :
						(Op == `BE_sw) ? 4'b1111 :
						(Op == `BE_sh) ? (Addr[1] == 1'b0 ? 4'b0011 : 4'b1100) :
						(Op == `BE_sb) ? ((Addr[1:0] == 2'b00) ? 4'b0001 :
										(Addr[1:0] == 2'b01) ? 4'b0010 :
										(Addr[1:0] == 2'b10) ? 4'b0100 : 4'b1000) : 
										4'b0000;
	assign tube_wdata = (Op == `BE_sw) ? WriteData :
						(Op == `BE_sh) ? (Addr[1]==1'b0 ? {16'b0, WriteData[15:0]} : {WriteData[15:0], 16'b0}) :
						(Op == `BE_sb) ? ((Addr[1:0] == 2'b00) ? {24'b0, WriteData[7:0]} :
										(Addr[1:0] == 2'b01) ? {16'b0, WriteData[7:0], 8'b0} :
										(Addr[1:0] == 2'b10) ? {8'b0, WriteData[7:0], 16'b0} : {WriteData[7:0], 24'b0}) : 32'd0;;					
	
endmodule