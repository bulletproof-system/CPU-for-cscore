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
`define ALU_syscall 6'd12


// Controller
`define op_R     6'b000000
`define op_addi  6'b001000
`define op_addiu 6'b001001
`define op_andi  6'b001100
`define op_ori   6'b001101
`define op_beq   6'b000100
`define op_bne   6'b000101
`define op_lb    6'b100000
`define op_lbu   6'b100100
`define op_lh    6'b100001
`define op_lhu   6'b100101
`define op_lw    6'b100011
`define op_sb    6'b101000
`define op_sh    6'b101001
`define op_sw    6'b101011
`define op_lui   6'b001111
`define op_j     6'b000010
`define op_jal   6'b000011
`define op_COP0  6'b010000
`define C0_mfc0  5'b00000
`define C0_mtc0  5'b00100
`define C0_eret  6'b011000
`define IM_4    3'b000
`define IM_j    3'b001
`define IM_jr   3'b010
`define IM_beq  3'b011
`define IM_bne  3'b100
`define WA_Sel_rd 2'b00
`define WA_Sel_rt 2'b01
`define WA_Sel_ra 2'b10
`define ALUData_Sel_out 2'b00
`define ALUData_Sel_pc  2'b01
`define ALUData_Sel_lo  2'b10
`define ALUData_Sel_hi  2'b11
`define RegData_Sel_out 2'b00
`define RegData_Sel_mem 2'b01
`define RegData_Sel_cp0 2'b10

// BE
`define BE_lw  4'd1
`define BE_lb  4'd2
`define BE_lbu 4'd3
`define BE_lh  4'd4
`define BE_lhu 4'd5
`define BE_sw  4'd6
`define BE_sb  4'd7
`define BE_sh  4'd8
`define BE_default  4'd0


// MD
`define MD_mfhi	 3'b000
`define MD_mflo	 3'b001
`define MD_mthi  3'b010
`define MD_mtlo  3'b011
`define MD_mult	 3'b100
`define MD_multu 3'b101 
`define MD_div	 3'b110
`define MD_divu	 3'b111
`define busy_zero 5'd0
`define busy_mult 5'd5
`define busy_div  5'd10

//ExcCode
`define Int  	5'd0  // 外部中断
`define AdEL 	5'd4  // 取指异常、取数异常
`define AdES 	5'd5  // 存数异常
`define Syscall	5'd8  // 系统调用
`define RI		5'd10 // 未知指令
`define Ov		5'd12 // 溢出异常

// Bridge
`define device_DM 3'd1 // 数据存储器
`define device_T0 3'd2 // 计时器 0
`define device_T1 3'd3 // 计时器 1
`define device_interrupt 3'd4 // 中断发生器
`define device_undefine 3'd0 // 未定义设备

// Instr_type
`define type_Load    4'd1 
`define type_Store   4'd2
`define type_CalOv   4'd3 
`define type_Lui     4'd4 
`define type_Link    4'd5 
`define type_MD      4'd6 
`define type_Mfc0    4'd7 
`define type_Eret	 4'd8
`define type_default 4'd0 
