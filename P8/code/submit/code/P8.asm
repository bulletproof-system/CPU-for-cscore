.macro uart_write(%data)
	wait:
	lw $t6, 0x7F34($0) # LSR
	andi $t6, $t6, 0x20
	beq $t6, $0, wait
	nop
	sw %data, 0x7F30($0) # DATA
.end_macro

.macro trans(%n)
	ori $t7, $0, 10
	subu $t7, %n, $t7
	slt $t7, $t7, $0
	bne $t7, $0, lt
	nop
ge:
	addi %n, %n, 39
lt:
	addi %n, %n, 48
.end_macro

.macro print(%n)
	lui $t7, 0x8000
	and $t7, %n, $t7
	or $t8, $0, %n
	beq $t7, $0, print_pos
	ori $t9, $0, 0x0
	subu $t8, $0, %n
	ori $t9, $0, 0x1
print_pos:
	beq $s1, $0, print_uart
	nop
print_tube:
	sw %n, 0x7F70($0) # LED
	sw $t8, 0x7F50($0) # tube[0]
	sw $t9, 0x7F54($0) # tube[1]
	j print_end
	nop
print_uart:
	beq $t9, $0, uart_pos
	ori $t5, $0, 45 # '-'
	uart_write($t5)
uart_pos:
	srl $t5, $t8, 28
	andi $t5, $t5, 0xf
	trans($t5)
	uart_write($t5)
	
	srl $t5, $t8, 24
	andi $t5, $t5, 0xf
	trans($t5)
	uart_write($t5)

	srl $t5, $t8, 20
	andi $t5, $t5, 0xf
	trans($t5)
	uart_write($t5)

	srl $t5, $t8, 16
	andi $t5, $t5, 0xf
	trans($t5)
	uart_write($t5)

	srl $t5, $t8, 12
	andi $t5, $t5, 0xf
	trans($t5)
	uart_write($t5)

	srl $t5, $t8, 8
	andi $t5, $t5, 0xf
	trans($t5)
	uart_write($t5)

	srl $t5, $t8, 4
	andi $t5, $t5, 0xf
	trans($t5)
	uart_write($t5)

	andi $t5, $t8, 0xf
	trans($t5)
	uart_write($t5)

print_end:

.end_macro

.text
start:
	ori $a0, $0, 0x2401 
	mtc0 $a0, $12 # 允许中断
	lb $v0, 0x7F68($0) # 按键开关
	andi $s0, $v0, 0x1 # $s0 模式控制
	beq $s0, $0, timer # 
	andi $s1, $v0, 0x2 # $s1 显示控制
calc: # 计算器模式
	andi $s2, $v0, 0x4 # $s2 按键 2
	andi $s3, $v0, 0x8 # $s3 按键 3
	andi $s4, $v0, 0x10 # $s4 按键 4
	andi $s5, $v0, 0x20 # $s5 按键 5
	andi $s6, $v0, 0x40 # $s6 按键 6
	andi $s7, $v0, 0x80 # $s7 按键 7
	lw $a1, 0x7F64($0) # 输入操作数 1
	lw $a2, 0x7F60($0) # 输入操作数 2
	beq $s2, $0, calc_add
	nop
	beq $s3, $0, calc_sub
	nop
	beq $s4, $0, calc_mult
	nop
	beq $s5, $0, calc_div
	nop
	beq $s6, $0, calc_and
	nop
	beq $s7, $0, calc_or
	nop
	j calc_default
	nop

	calc_add:
		addu $a3, $a1, $a2
		j calc_print
		nop
	calc_sub:
		subu $a3, $a1, $a2
		j calc_print
		nop
	calc_mult:
		mult $a1, $a2
		mflo $a3
		j calc_print
		nop
	calc_div:
		div $a1, $a2
		mflo $a3
		j calc_print
		nop
	calc_and:
		and $a3, $a1, $a2
		j calc_print
		nop
	calc_or:
		or $a3, $a1, $a2
		j calc_print
		nop
	calc_default:
		j calc_print
		nop
timer: # 计时器模式
	lw $a0, 0x7F60($0) # 输入初值
	lui $a2, 0x017d 
	ori $a2, $a2, 0x7840 # 计时器初值 25M
	sw $a2, 0x7F04($0) 
	andi $s2, $v0, 0x4 # 计数方式
	beq $s2, $0, down # 
	ori $a1, $0, 0x9 # 计数器控制器

	up: # 向上计数
		ori $a3, $0, 0
		print($a3)
		sw $a1, 0x7F00($0) # 开始计时
		wait_up:
			lw $t0, 0x7F60($0) # 输入初值
			bne $t0, $a0, start # 初值变化时重启
			nop
			bne $a3, $a0, wait_up # 等待计时终止
			nop
			sw $0, 0x7F00($0) # 停止计时
			j end_timer
			nop
	down: # 向下计数
		or $a3, $0, $a0
		print($a3)
		sw $a1, 0x7F00($0) # 开始计时
		wait_down:
			lw $t0, 0x7F60($0) # 输入初值
			bne $t0, $a0, start # 初值变化时重启
			nop
			bne $a3, $0, wait_down # 等待计时终止
			nop
			sw $0, 0x7F00($0) # 停止计时
			j end_timer
			nop

end_timer:
	lw $t0, 0x7F60($0) # 输入初值
	bne $t0, $a0, start # 初值变化时重启
	nop
	lb $t1, 0x7F68($0) # 输入初值
	bne $t1, $v0, start # 初值变化时重启
	nop
	j end_timer
	nop

calc_print:
	print($a3)
end_calc:
	lw $t1, 0x7F64($0) # 输入初值
	bne $t1, $a1, start # 初值变化时重启
	nop
	lw $t1, 0x7F60($0) # 输入初值
	bne $t1, $a2, start # 初值变化时重启
	nop
	lb $t1, 0x7F68($0) # 输入初值
	bne $t1, $v0, start # 初值变化时重启
	nop
	j end_calc
	nop

.ktext 0x4180
_entry:
	jal _save_context
	nop
	mfc0 $k0, $13
	andi $t0, $k0, 0x7C 
	beq $t0, $0, _interrupt
	mfc0 $k1, $14

_exc: # 异常处理
	addiu $k1, $k1, 4
	mtc0 $k1, $14
	j _end
	nop

_interrupt: # 中断处理
	andi $t0, $k0, 0x400
	bne $t0, $0, _timer
	nop
_uart: # uart 回显
	lw $t0, 0x7F30($0)
	uart_write($t0)
	j _end
	nop

_timer: # 处理计时器中断
	beq $s2, $0, _down # 
	ori $t1, $0, 0x1
_up:
	addu $a3, $a3, $t1
	j _next_time
	nop
_down:
	subu $a3, $a3, $t1
_next_time:
	print($a3)
	sw $a1, 0x7F00($0) # 开始计时
	j _end
	nop

_save_context:
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	sw $t4, 20($sp)
	sw $t5, 24($sp)
	sw $t6, 28($sp)
	sw $t7, 32($sp)
	sw $t8, 36($sp)
	sw $t9, 40($sp)
	jr $ra
	nop
_load_context:
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	lw $t4, 20($sp)
	lw $t5, 24($sp)
	lw $t6, 28($sp)
	lw $t7, 32($sp)
	lw $t8, 36($sp)
	lw $t9, 40($sp)
	jr $ra
	nop

_end:
	jal _load_context
	nop
	eret
	nop
