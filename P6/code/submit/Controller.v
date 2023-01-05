`timescale 1ns / 1ps
`default_nettype none
`include "Gobals.v"

module Controller(
	input wire [31:0] instr,
	output wire [2:0] IMControl,
	output wire [1:0] WA_Sel, ALUData_Sel,
	output wire ALUSrc, Ext, RegWrite, start,
	output wire [2:0] BEop, MDop,
	output wire [5:0] ALUop,
	output wire [1:0] RegData_Sel,
	output wire [4:0] rs_Addr, rt_Addr,
	output wire [2:0] T_new, rs_T_use, rt_T_use,
	output wire link, LUI, MD_
);
	wire [5:0] opcode;
	wire [5:0] funct;
	assign opcode = instr[31:26];
	assign funct  = instr[5:0];
	wire add, sub, and_, or_, slt, sltu, addu, subu;
	wire addi, andi, ori, sll;
	wire beq, bne;
	wire mfhi, mflo;
	wire mthi, mtlo;
	wire mult, multu, div, divu;
	wire lb, lh, lw, lbu, lhu;
	wire sb, sh, sw;
	wire lui, jal, j, jalr, jr;
	wire Cal_rr, Cal_ri, Br_r1, Br_r2, Mv_fr, Mv_to, Load, Store, Mul_div, Lui, Jal, J, Jalr, Jr;
	// Cal_rr
	assign add  = (opcode == `op_R && funct == `ALU_add);
	assign sub  = (opcode == `op_R && funct == `ALU_sub);
	assign and_ = (opcode == `op_R && funct == `ALU_and);
	assign or_  = (opcode == `op_R && funct == `ALU_or);
	assign slt  = (opcode == `op_R && funct == `ALU_slt);
	assign sltu = (opcode == `op_R && funct == `ALU_sltu);
	assign addu = (opcode == `op_R && funct == `ALU_addu);
	assign subu = (opcode == `op_R && funct == `ALU_subu);

	// Cal_ri
	assign addi = (opcode == `op_addi);
	assign andi = (opcode == `op_andi);
	assign ori  = (opcode == `op_ori);
	assign sll  = (opcode == `op_R && funct == `ALU_sll);

	// Br_r1
	

	// Br_r2
	assign beq  = (opcode == `op_beq);
	assign bne  = (opcode == `op_bne);

	// Mv_fr
	assign mfhi = (opcode == `op_R && funct == `ALU_mfhi);
	assign mflo = (opcode == `op_R && funct == `ALU_mflo);

	// Mv_to
	assign mthi = (opcode == `op_R && funct == `ALU_mthi);
	assign mtlo = (opcode == `op_R && funct == `ALU_mtlo);

	// Load
	assign lb  = (opcode == `op_lb);
	assign lbu  = (opcode == `op_lbu);
	assign lh  = (opcode == `op_lh);
	assign lhu  = (opcode == `op_lhu);
	assign lw  = (opcode == `op_lw);

	// Store
	assign sb  = (opcode == `op_sb);
	assign sh  = (opcode == `op_sh);
	assign sw  = (opcode == `op_sw);

	// Mul_div
	assign mult = (opcode == `op_R && funct == `ALU_mult);
	assign multu = (opcode == `op_R && funct == `ALU_multu);
	assign div = (opcode == `op_R && funct == `ALU_div);
	assign divu = (opcode == `op_R && funct == `ALU_divu);

	// Lui
	assign lui = (opcode == `op_lui);

	// Jal
	assign jal = (opcode == `op_jal);

	// J
	assign j   = (opcode == `op_j  );

	// Jalr
	assign jalr = (opcode == `op_R && funct == `ALU_jalr);

	// Jr
	assign jr  = (opcode == `op_R && funct == `ALU_jr);


	assign Cal_rr = (add || sub || and_ || or_ || slt || sltu || addu || subu || sll);
	assign Cal_ri = (addi || andi || ori);
	assign Br_r1 = 1'b0;
	assign Br_r2 = (beq || bne);
	assign Mv_fr = (mfhi || mflo);
	assign Mv_to = (mthi || mtlo);
	assign Load  = (lb || lh || lw || lbu || lhu);
	assign Store = (sb || sh || sw);
	assign Mul_div = (mult || multu || div || divu);
	assign Lui   = lui;
	assign Jal   = jal;
	assign J	 = j;
	assign Jalr  = jalr;
	assign Jr	 = jr;

	assign IMControl = (Cal_rr || Cal_ri || Mv_fr || Mv_to || Load || Store || Mul_div || Lui) ? `IM_4 :
					   (Jal || J) ? `IM_j : 
					   (Jalr || Jr) ? `IM_jr :
					   (beq) ? `IM_beq : 
					   (bne) ? `IM_bne : 3'b000;
	assign WA_Sel = (Cal_rr || Mv_fr || Jalr) ? `WA_Sel_rd :
					(Cal_ri || Load || Lui) ? `WA_Sel_rt : 
					(Jal) ? `WA_Sel_ra : 2'b00;
	assign ALUData_Sel = (Cal_rr || Cal_ri || Load || Store || Lui) ? `ALUData_Sel_out :
						 (Jal || Jalr) ? `ALUData_Sel_pc :
						 (mflo) ? `ALUData_Sel_lo : 
						 (mfhi) ? `ALUData_Sel_hi : 2'b0;
	assign ALUSrc = (Cal_ri || Load || Store);
	assign Ext    = (addi || Load || Store);
	assign ALUop  = (Cal_rr) ? funct : 
					addi ? `ALU_addu : 
					andi ? `ALU_and  : 
					ori  ? `ALU_or	 : 
					(Load || Store) ? `ALU_addu :
					Lui ? `ALU_lui : 6'b0;
	assign BEop = lw  ? `BE_lw  :
				  lb  ? `BE_lb  :
				  lbu ? `BE_lbu : 
				  lh  ? `BE_lh  : 
				  lhu ? `BE_lhu : 
				  sw  ? `BE_sw  : 
				  sb  ? `BE_sb  :
				  sh  ? `BE_sh  : 3'b000;
	assign MDop = mfhi  ? `MD_mfhi :
				  mflo  ? `MD_mflo :
				  mthi  ? `MD_mthi : 
				  mtlo  ? `MD_mtlo : 
				  mult  ? `MD_mult : 
				  multu ? `MD_multu :
				  div	? `MD_div :
				  divu	? `MD_divu : 3'b000;
	
	assign RegData_Sel = (Cal_rr || Cal_ri || Mv_fr || Jal || Jalr) ? `RegData_Sel_out :
						  (Load) ? `RegData_Sel_mem :
						  2'b0;
	assign RegWrite = (Cal_rr || Cal_ri || Mv_fr || Load || Lui || Jal || Jalr);
	assign start = Mul_div;
	assign rs_Addr = instr[25:21];
	assign rt_Addr = instr[20:16];
	assign T_new   = (Cal_rr || Cal_ri || Mv_fr) ? 3'd2 : 
					 (Load) ? 3'd3 :
					 (Lui)  ? 3'd1 :
					 (Jal || Jalr) ? 3'd1 : 3'd5;
	assign rs_T_use = (Cal_rr || Cal_ri || Mv_to || Load || Store || Mul_div) ? 3'd1 : 
					  (Br_r2 || Jr || Jalr) ? 3'd0 : 
					  3'd5;
	assign rt_T_use = (Cal_rr || Mul_div) ? 3'd1 : 
					  (Br_r2)  ? 3'd0 : 
					  (Store)  ? 3'd2 : 
					  3'd5;
	assign link = (Jal || Jalr);
	assign LUI = Lui;
	assign MD_ = Mv_fr || Mv_to;
endmodule


module Hazard_Controller (
	input wire clk,
	input wire reset,
	input wire MD_,
	input wire [4:0] D_rs_Addr,
	input wire [2:0] D_rs_T_use,
	input wire [4:0] D_rt_Addr,
	input wire [2:0] D_rt_T_use,
	input wire [4:0] E_RegWA,
	input wire [2:0] E_T_new,
	input wire E_RegWrite, E_busy,
	input wire E_lui, E_link,
	input wire [4:0] M_RegWA,
	input wire [2:0] M_T_new,
	input wire M_RegWrite,
	input wire W_RegWrite,
	output wire [1:0] D_D1_Sel,
	output wire [1:0] D_D2_Sel,
	output reg  [1:0] E_D1_Sel,
	output reg [1:0] E_D2_Sel,
	output wire block,
	output reg WriteData_Sel
);
	wire E_rs_FW, E_rt_FW, M_rs_FW, M_rt_FW, WriteData_Sel_2;
	wire [1:0] E_D1_Sel_1, E_D2_Sel_1;
	reg  WriteData_Sel_1;
	always @ (posedge clk) begin
		if(reset) begin
			E_D1_Sel <= 32'b0;
			E_D2_Sel <= 32'b0;
			WriteData_Sel <= 32'b0;
			WriteData_Sel_1 <= 32'b0;
		end else if(block) begin
			E_D1_Sel <= 32'b0;
			E_D2_Sel <= 32'b0;
			WriteData_Sel <= WriteData_Sel_1;
			WriteData_Sel_1 <= 1'b0;
		end else begin
			E_D1_Sel <= E_D1_Sel_1;
			E_D2_Sel <= E_D2_Sel_1;
			WriteData_Sel <= WriteData_Sel_1;
			WriteData_Sel_1 <= WriteData_Sel_2;
		end
	end
	assign block = (D_rs_Addr == E_RegWA && D_rs_Addr != 5'b0 && E_RegWrite && D_rs_T_use < E_T_new) ||
				   (D_rt_Addr == E_RegWA && D_rt_Addr != 5'b0 && E_RegWrite && D_rt_T_use < E_T_new) ||
				   (D_rs_Addr == M_RegWA && D_rs_Addr != 5'b0 && M_RegWrite && D_rs_T_use < M_T_new) ||
				   (D_rt_Addr == M_RegWA && D_rt_Addr != 5'b0 && M_RegWrite && D_rt_T_use < M_T_new) || 
				   (MD_ && E_busy);
	assign E_rs_FW = (D_rs_Addr == E_RegWA && D_rs_Addr != 5'b0 && E_RegWrite && D_rs_T_use >= E_T_new);
	assign M_rs_FW = (D_rs_Addr == M_RegWA && D_rs_Addr != 5'b0 && M_RegWrite && D_rs_T_use >= M_T_new) && !E_rs_FW;
	assign E_rt_FW = (D_rt_Addr == E_RegWA && D_rt_Addr != 5'b0 && E_RegWrite && D_rt_T_use >= E_T_new);
	assign M_rt_FW = (D_rt_Addr == M_RegWA && D_rt_Addr != 5'b0 && M_RegWrite && D_rt_T_use >= M_T_new) && !E_rt_FW;
	assign D_D1_Sel = (E_rs_FW && E_T_new == 2'b0) ? (E_link ? 2'd3 : 2'd2) : 
					  (M_rs_FW && M_T_new == 2'b0) ? 2'd1 : 2'd0;
	assign D_D2_Sel = (E_rt_FW && E_T_new == 2'b0) ? (E_link ? 2'd3 : 2'd2) : 
					  (M_rt_FW && M_T_new == 2'b0) ? 2'd1 : 2'd0;
	assign E_D1_Sel_1 = (E_rs_FW && E_T_new == 2'b1) ? 2'd1 : 
						(M_rs_FW && M_T_new == 2'b1) ? 2'd2 : 2'd0;
	assign E_D2_Sel_1 = (E_rt_FW && E_T_new == 2'b1) ? 2'd1 : 
						(M_rt_FW && M_T_new == 2'b1) ? 2'd2 : 2'd0;
	assign WriteData_Sel_2 = (E_rt_FW && E_T_new == 2'd2) ? 1'd1 : 1'd0;

endmodule //Hazard_Controller