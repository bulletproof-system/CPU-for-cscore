# 模块设计

## 顶层模块

### mips

- 实例化其他模块并连接
- 输出

## control

### Controller

- 控制器
- 输入

	- `opcode [5:0]` 
	- `funct [5:0]`
- 输出
	- `IMControl [1:0]` 
	- `RegWAC [1:0]`
	- `RegWDC [1:0]`
	- `RegWrite`
	- `MemWrite`
	- `ALUSrc`
	- `ALUControl [5:0]`
	- `Ext [1:0]`

## datapath

### ALU

- 计算单元
- 输入
	- `D1 [31:0]`
	- `D2 [31:0]`
	- `op [5:0]`

- 输出
	- `Zero`
	- `out [31:0]`

### DM

- 数据储存器
- 输入
	- `clk`
	- `reset`
	- `MemWrite`
	- `Addr [15:0]`
	- `WriteData [31:0]`
- 输出
	- `ReadData [31:0]`

- 存储大小 `[0: 0x2FFF]`

### Extend

- 扩展单元
- 输入
	- `imm [15:0]`
	- `Ext [1:0]`
- 输出
	- `imm32 [32:0]`

### GRF

- 寄存器堆
- 输入
	- `clk`
	- `reset`
	- `RA1 [4:0]`
	- `RA2 [4:0]`
	- `RegWrite`
	- `WA [4:0]`
	- `WD [31:0]`
- 输出
	- `RD1 [31:0]`
	- `RD2 [31:0]`
- `$0` 始终为 0

### IM

- 指令存储器
- 输入
	- `clk`
	- `reset`
	- `nPC [31:0]`
- 输出
	- `reg [31:0] PC`
	- `[31:0] instr`
- 地址范围 `[0x3000: 0x3FFF]`
- 读取 `code.txt` 文件

### PC_Calc

- 计算下一 PC 值
- 输入
	- `PC [31:0]`
	- `instr_index [25:0]`
	- `offset [15:0]`
	- `Zero`
	- `RegData [31:0]`
	- `IMControl [1:0]`
- 输出
	- `nPC [31:0]`
	- `PC4 [31:0]`

### Mux

- 多路选择器

# 思考题

1. > 阅读下面给出的 DM 的输入示例中（示例 DM 容量为 4KB，即 32bit × 1024字），根据你的理解回答，这个 addr 信号又是从哪里来的？地址信号 addr 位数为什么是 [11:2] 而不是 [9:0] ？

	DM 按字寻址， 而 MIPS 中是按字节寻址。

2. > 思考上述两种控制器设计的译码方式，给出代码示例，并尝试对比各方式的优劣。

	- **控制信号每种取值所对应的指令**
	
	  ```verilog
	  assign ctrlsign = (instr1 || instr2 || instr3)
	  ```

	  只需列出每种信号的对应指令，不需要考虑其他不需要该信号的指令

	- **指令对应的控制信号如何取值**
	
	  ```verilog
	  always @(*) begin
	      if(instr1) begin
	          ctrlsign1 = 1'b1
	          ctrlsign2 = 1'b0
	          ...
	      end else if(instr2) begin
	          ctrlsign1 = 1'b0
	          ctrlsign2 = 1'b1
	          ...
	      end
	  end
	  ```

	  每条指令都要列出所有控制信号，便于添加指令
	
3. > 在相应的部件中，复位信号的设计都是**同步复位**，这与 P3 中的设计要求不同。请对比**同步复位**与**异步复位**这两种方式的 reset 信号与 clk 信号优先级的关系。

   - 同步复位 clk 优先级高
   - 异步复位 reset 优先级高

4. >C 语言是一种弱类型程序设计语言。C 语言中不对计算结果溢出进行处理，这意味着 C 语言要求程序员必须很清楚计算结果是否会导致溢出。因此，如果仅仅支持 C 语言，MIPS 指令的所有计算指令均可以忽略溢出。 请说明为什么在忽略溢出的前提下，addi 与 addiu 是等价的，add 与 addu 是等价的。提示：阅读《MIPS32® Architecture For Programmers Volume II: The MIPS32® Instruction Set》中相关指令的 Operation 部分。

   - `add` 和 `addi` 都会符号扩展最高位一位来判断是否溢出，忽略溢出即在 $\mod 2^{32}$ 下进行运算，扩展后最高位是 $2^{32}$ 的倍数，对运算结果无影响，此时低 32 位的运算结果等价于 `addu` 和 `addiu` 

# 测试方案

- 由于忽略溢出，计算的测试可以很简单的测试一下正负数，主要检查零扩展和符号扩展
- 通过 `lw` 和 `sw` 检查数据存储器
- 测试跳转和分支指令时主要测试向上跳转，以测试符号扩展是否可用。
- 自动化测试见 [自动化测试](README.md) 
