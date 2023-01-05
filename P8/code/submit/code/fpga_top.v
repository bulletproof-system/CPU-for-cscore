/* Template Top Module for CO-FPGA */
`timescale 1ns / 1ps
`default_nettype none
`include "Gobals.v"
`ifdef IVERILOG
`include "mips.v"
`include "Memory.v"
`include "Bridge.v"
`include "P7_standard_timer_2019.v"
`include "UART.v"
`endif

module fpga_top (
    // clock and reset
    input wire clk_in,
    input wire sys_rstn,
    // dip switch
    input wire [7:0] dip_switch0,
    input wire [7:0] dip_switch1,
    input wire [7:0] dip_switch2,
    input wire [7:0] dip_switch3,
    input wire [7:0] dip_switch4,
    input wire [7:0] dip_switch5,
    input wire [7:0] dip_switch6,
    input wire [7:0] dip_switch7,
    // key
    input wire [7:0] user_key,
    // led
    output wire [31:0] led_light,
    // digital tube
    output wire [7:0] digital_tube2,
    output wire digital_tube_sel2,
    output wire [7:0] digital_tube1,
    output wire [3:0] digital_tube_sel1,
    output wire [7:0] digital_tube0,
    output wire [3:0] digital_tube_sel0,
    // uart
    input wire uart_rxd,
    output wire uart_txd
);

    // Your code here
    wire clk; 
	wire reset;

	wire [31:0] i_inst_addr;
	wire [31:0] i_inst_rdata;

    wire [31:0] Bridge_Addr, Bridge_WriteData, Bridge_ReadData;
    wire [5:0] HWIn;
    wire [4:0] Bridge_ExcCodeIn, Bridge_ExcCodeOut;
	wire [3:0] Bridge_Op;
    wire Bridge_Req;

    CPU CPU(
		.clk(clk),
		.reset(reset),

		.i_inst_addr(i_inst_addr),
		.i_inst_rdata(i_inst_rdata),

        .Bridge_Addr(Bridge_Addr),
        .Bridge_WriteData(Bridge_WriteData),
        .Bridge_ExcCodeIn(Bridge_ExcCodeIn),
        .Bridge_Op(Bridge_Op), .Bridge_Req(Bridge_Req),
        .Bridge_ReadData(Bridge_ReadData),
        .Bridge_ExcCodeOut(Bridge_ExcCodeOut),
        .HWIn(HWIn)
	);
    assign clk = clk_in;
    assign reset = ~sys_rstn;
    assign HWIn = {2'b0, IRQ_UART, 2'b0, IRQ_T0};

    Bridge Bridge(.clk(clk), .reset(reset), .Addr(Bridge_Addr), .WriteData(Bridge_WriteData), .ExcCodeIn(Bridge_ExcCodeIn), 
                  .Op(Bridge_Op), .ReadData(Bridge_ReadData),
                  .ExcCodeOut(Bridge_ExcCodeOut), .Req(Bridge_Req),

                  .m_data_addr(m_data_addr), .m_data_rdata(m_data_rdata), .m_data_wdata(m_data_wdata), .m_data_byteen(m_data_byteen),
                  
                  .Addr_T0(Addr_T0), .WE_T0(WE_T0), .Din_T0(Din_T0), .Dout_T0(Dout_T0),

                  .dip_switch_3_0(~{dip_switch3, dip_switch2, dip_switch1, dip_switch0}),
                  .dip_switch_7_4(~{dip_switch7, dip_switch6, dip_switch5, dip_switch4}),

                  .user_key(user_key),

                  .led_byteen(led_byteen), .led_wdata(led_wdata),

                  .tube_wdata(tube_wdata), .tube_byteen(tube_byteen), .tube_addr(tube_addr),

                  .uart_we(uart_we), .uart_load(uart_load), 
                  .uart_addr(uart_addr), .uart_wdata(uart_wdata), .uart_rdata(uart_rdata)
    );
                  
    // assign led_light = ~{dip_switch3, dip_switch2, dip_switch1, dip_switch0};

    
    wire IRQ_T0, WE_T0;
    wire [31:2] Addr_T0;
    wire [31:0] Dout_T0, Din_T0;
    TC T0(.clk(clk), .reset(reset), .Addr(Addr_T0), .WE(WE_T0), .Din(Din_T0), .Dout(Dout_T0), .IRQ(IRQ_T0));

    IM IM( 
        .clka(clk), // input clka
        .addra(i_inst_addr[13:2]), // input [11 : 0] addra
        .douta(i_inst_rdata) // output [31 : 0] douta
    );
    wire [31:0] m_data_addr;
	wire [31:0] m_data_rdata;
	wire [31:0] m_data_wdata;
	wire [3 :0] m_data_byteen;
    DM DM(
        .clka(clk), // input clka
        .wea(m_data_byteen), // input [3 : 0] wea
        .addra(m_data_addr[13:2]), // input [11 : 0] addra
        .dina(m_data_wdata), // input [31 : 0] dina
        .douta(m_data_rdata) // output [31 : 0] douta
    );
    // CLOCK CLOCK(// Clock in ports
    //     .CLK_IN1(clk_in),      // IN
    //     // Clock out ports
    //     // .CLK_OUT1(CLK_OUT1),     // 10M
    //     // .CLK_OUT2(CLK_OUT2),     // 20M
    //     // .CLK_OUT3(CLK_OUT3),     // 30M
    //     .CLK_OUT1(clk)      // 25M
    // );
    wire tube_addr;
    wire [3:0] tube_byteen;
    wire [31:0] tube_wdata;
    digital_tube digital_tube(
        .clk(clk), .reset(reset), .byteen(tube_byteen), 
        .Addr(tube_addr), .wdata(tube_wdata),
        .digital_tube2(digital_tube2), .digital_tube_sel2(digital_tube_sel2),
        .digital_tube1(digital_tube1), .digital_tube_sel1(digital_tube_sel1),
        .digital_tube0(digital_tube0), .digital_tube_sel0(digital_tube_sel0)
    );
    wire [3:0] led_byteen;
    wire [31:0] led_wdata;
    LED_CTRL LED_CTRL(
        .clk(clk), .reset(reset),
        .byteen(led_byteen), .wdata(led_wdata),
        .led_light(led_light)
    );
    wire uart_we, uart_load, IRQ_UART;
    wire [1:0] uart_addr;
    wire [31:0] uart_wdata, uart_rdata;
    UART UART(
        .clk(clk), .rstn(sys_rstn), .we(uart_we), .load(uart_load), .IRQ(IRQ_UART),
        .uart_rxd(uart_rxd), .uart_txd(uart_txd),
        .Addr(uart_addr), .wdata(uart_wdata), .rdata(uart_rdata)
    );

    // Default assignment for peripherals not in use. Comment corresponding line(s) if you use them.
    // UART: idle
    // assign uart_txd = 1'b1;
    // LED: off
    // assign led_light = 32'hFFFF_FFFF;
    // Digital tube: off
    // assign digital_tube_sel0 = 4'b1111;
    // assign digital_tube_sel1 = 4'b1111;
    // assign digital_tube_sel2 = 1'b1;
    // assign digital_tube0 = 8'hFF;
    // assign digital_tube1 = 8'hFF;
    // assign digital_tube2 = 8'hFF;

endmodule

module digital_tube (
    input wire clk, reset,
    input wire [3:0] byteen,
    input wire Addr,
    input wire [31:0] wdata,

    output wire [7:0] digital_tube2,
    output reg digital_tube_sel2,
    output wire [7:0] digital_tube1,
    output reg [3:0] digital_tube_sel1,
    output wire [7:0] digital_tube0,
    output reg [3:0] digital_tube_sel0
);
    localparam PERIOD = 32'd25_000;
    // div counter
    reg [31:0] counter;
    always @(posedge clk) begin
        if (reset) begin
            counter <= 0;
        end
        else begin
            if (counter + 1 == PERIOD) 
                counter <= 0;
            else
                counter <= counter + 1;
        end
    end

    reg [31:0] tube [0:1];
    wire [31:0] save_data;
    assign save_data[7:0] = byteen[0] ? wdata[7:0] : tube[Addr][7:0];
    assign save_data[15:8] = byteen[1] ? wdata[15:8] : tube[Addr][15:8];
    assign save_data[23:16] = byteen[2] ? wdata[23:16] : tube[Addr][23:16];
    assign save_data[31:24] = byteen[3] ? wdata[31:24] : tube[Addr][31:24];
    always @(posedge clk) begin
		if(reset) begin
			tube[0] <= 32'h0;
			tube[1] <= 32'h0;
        end else if(|byteen) begin
			tube[Addr] <= save_data;
		end
	end
    always @(posedge clk) begin
        if(reset) begin
            digital_tube_sel0 <= 4'h1;
            digital_tube_sel1 <= 4'h1;
            digital_tube_sel2 <= 1'b1;
        end else if (counter + 1 == PERIOD) begin
            digital_tube_sel0 <= {digital_tube_sel0[0], digital_tube_sel0[3:1]};
            digital_tube_sel1 <= {digital_tube_sel1[0], digital_tube_sel1[3:1]};
        end
    end
    assign digital_tube0 = (digital_tube_sel0 == 4'b0001) ? hex2dig(tube[0][3:0]) :
                           (digital_tube_sel0 == 4'b0010) ? hex2dig(tube[0][7:4]) :
                           (digital_tube_sel0 == 4'b0100) ? hex2dig(tube[0][11:8]) :
                           (digital_tube_sel0 == 4'b1000) ? hex2dig(tube[0][15:12]) :
                            8'b1111_1111;
    assign digital_tube1 = (digital_tube_sel1 == 4'b0001) ? hex2dig(tube[0][19:16]) :
                           (digital_tube_sel1 == 4'b0010) ? hex2dig(tube[0][23:20]) :
                           (digital_tube_sel1 == 4'b0100) ? hex2dig(tube[0][27:24]) :
                           (digital_tube_sel1 == 4'b1000) ? hex2dig(tube[0][31:28]) :
                            8'b1111_1111;
    assign digital_tube2 = (|tube[1]) ? 8'b1111_1110 : 8'b1111_1111;
    function [7:0] hex2dig;
        input [3:0] hex;
        begin
            case (hex)
                4'h0    : hex2dig = 8'b1000_0001;   // not G
                4'h1    : hex2dig = 8'b1100_1111;   // B, C
                4'h2    : hex2dig = 8'b1001_0010;   // not C, F
                4'h3    : hex2dig = 8'b1000_0110;   // not E, F
                4'h4    : hex2dig = 8'b1100_1100;   // not A, D, E
                4'h5    : hex2dig = 8'b1010_0100;   // not B, E
                4'h6    : hex2dig = 8'b1010_0000;   // not B
                4'h7    : hex2dig = 8'b1000_1111;   // A, B, C
                4'h8    : hex2dig = 8'b1000_0000;   // All
                4'h9    : hex2dig = 8'b1000_0100;   // not E
                4'hA    : hex2dig = 8'b1000_1000;   // not D
                4'hB    : hex2dig = 8'b1110_0000;   // not A, B
                4'hC    : hex2dig = 8'b1011_0001;   // A, D, E, F
                4'hD    : hex2dig = 8'b1100_0010;   // not A, F
                4'hE    : hex2dig = 8'b1011_0000;   // not B, C
                4'hF    : hex2dig = 8'b1011_1000;   // A, E, F, G
                default : hex2dig = 8'b1111_1111;
            endcase
        end

    endfunction
endmodule //digital_tube

module LED_CTRL (
    input wire clk, reset,
    input wire [3:0] byteen,
    input wire [31:0] wdata,

    output reg [31:0] led_light
);
    wire [31:0] save_data;
    assign save_data[7:0] = byteen[0] ? wdata[7:0] : led_light[7:0];
    assign save_data[15:8] = byteen[1] ? wdata[15:8] : led_light[15:8];
    assign save_data[23:16] = byteen[2] ? wdata[23:16] : led_light[23:16];
    assign save_data[31:24] = byteen[3] ? wdata[31:24] : led_light[31:24];
    always @(posedge clk) begin
		if(reset) begin
			led_light <= 32'hFFFF_FFFF;
		end else if(|byteen) begin
			led_light <= ~save_data;
		end
	end
endmodule //LED_CTRL

module UART (
    input wire clk, rstn, we, load, uart_rxd,
    input wire [1:0] Addr,
    input wire [31:0] wdata,

    output wire uart_txd, IRQ,
    output wire [31:0] rdata
);
    reg [15:0] DIVR, DIVT;

    wire uart_ready, uart_busy, uart_we, uart_load;
    wire [7:0] uart_wdata, uart_rdata;

    assign IRQ = uart_ready;
    assign uart_wdata = wdata[7:0];
    assign rdata = (Addr == 2'd0) ? {24'd0, uart_rdata} :
                   (Addr == 2'd1) ? {26'b0, ~uart_busy, 4'b0, uart_ready} :
                   (Addr == 2'd2) ? {16'b0, DIVR} : {16'b0, DIVT};
    assign uart_we = (Addr == 2'd0) && we;
    assign uart_load = (Addr == 2'd0) && load;

    always @(posedge clk) begin
        if(~rstn) begin
            DIVR <= `PERIOD_BAUD_115200;
            DIVT <= `PERIOD_BAUD_115200;
        end else if(we) begin
            case (Addr)
                2'd2 : DIVR <= wdata[15:0];
                2'd3 : DIVT <= wdata[15:0];
            endcase
        end
    end

    UART_CTRL UART_CTRL(
        .clk(clk), .rstn(rstn), .we(uart_we), .load(uart_load),
        .wdata(uart_wdata), .rdata(uart_rdata), 
        .DIVR(DIVR), .DIVT(DIVT),
        .uart_rxd(uart_rxd), .uart_txd(uart_txd),
        .uart_ready(uart_ready), .uart_busy(uart_busy)
    );
endmodule //UART

module UART_CTRL (
    input wire clk, rstn, we, load,
    input wire [7:0] wdata,
    output wire [7:0] rdata,

    input wire [15:0] DIVR, DIVT,
    input wire uart_rxd,
    output wire uart_txd, 
    output wire uart_ready,
    output wire uart_busy
);
    integer i;
    parameter buffer_size = 32;
    wire tx_start, tx_avai;
    wire [15:0] period;

    assign uart_busy = (num == 5'd31);
    assign tx_start = tx_avai && (num != 5'd0);
    // assign period = `PERIOD_BAUD_115200;

    reg [4:0] num;
    reg [7:0] buffer [0:buffer_size-1];
    always @(posedge clk) begin
        if(~rstn) begin
            num <= 5'd0;
            for(i=0; i<buffer_size; i=i+1) buffer[i] <= 8'd0;
        end else if(we) begin
            num <= num + 5'd1;
            buffer[num] <= wdata;
        end else if(tx_start) begin
            num <= num - 5'd1;
            for(i=0; i<buffer_size-1; i=i+1) buffer[i] <= buffer[i+1];
        end
    end
    uart_tx uart_tx(
        .clk(clk), .rstn(rstn), .period(DIVT),
        .tx_start(tx_start), .tx_data(buffer[0]),
        .txd(uart_txd), .tx_avai(tx_avai)
    );
    uart_rx uart_rx(
        .clk(clk), .rstn(rstn), .period(DIVR),
        .rxd(uart_rxd), .rx_clear(load), 
        .rx_data(rdata), .rx_ready(uart_ready)
    );
endmodule //UART