// ALUop
`define ALU_add   6'd32
`define ALU_sub   6'd34
`define ALU_and   6'd36
`define ALU_or    6'd37
`define ALU_slt   6'd42
`define ALU_sltu  6'd43
`define ALU_addu  6'd33
`define ALU_subu  6'd35
`define ALU_sll   6'd0
`define ALU_mfhi  6'd16
`define ALU_mflo  6'd18
`define ALU_mthi  6'd17
`define ALU_mtlo  6'd19
`define ALU_mult  6'd24
`define ALU_multu 6'd25
`define ALU_div   6'd26
`define ALU_divu  6'd27
`define ALU_jalr  6'd9
`define ALU_jr    6'd8
`define ALU_lui   6'd1


// Controller
`define op_R    6'b000000
`define op_addi 6'b001000
`define op_andi 6'b001100
`define op_ori  6'b001101
`define op_beq  6'b000100
`define op_bne  6'b000101
`define op_lb   6'b100000
`define op_lbu  6'b100100
`define op_lh   6'b100001
`define op_lhu  6'b100101
`define op_lw   6'b100011
`define op_sb   6'b101000
`define op_sh   6'b101001
`define op_sw   6'b101011
`define op_lui  6'b001111
`define op_j    6'b000010
`define op_jal  6'b000011
`define IM_4    3'b000
`define IM_j    3'b001
`define IM_jr   3'b010
`define IM_beq  3'b011
`define IM_bne  3'b100
`define WA_Sel_rd 2'b00
`define WA_Sel_rt 2'b01
`define WA_Sel_ra 2'b10
`define RegData_Sel_out 2'b00
`define RegData_Sel_mem 2'b01
