`timescale 1ns / 1ps
`default_nettype none
`include "Gobals.v"

module ALU(
    input wire [31:0] D1,
    input wire [31:0] D2,
	input wire [15:0] Imm,
    input wire [5:0]  ALUop,
	input wire ALUSrc,
    input wire Ext,
    input wire [3:0] Instr_type,
    input wire [4:0] ExcCodeIn,
    output wire [31:0] out,
    output wire [4:0] ExcCodeOut
    );
	wire [31:0] A, B, Imm32;
    wire [32:0] temp;
	assign Imm32 = Ext ? {{16{Imm[15]}}, Imm} : {16'b0, Imm};
	assign A = D1;
	assign B = ALUSrc ? Imm32 : D2;
    assign out = (ALUop == `ALU_add) ? A + B :
                 (ALUop == `ALU_sub) ? A - B :
                 (ALUop == `ALU_and) ? A & B :
                 (ALUop == `ALU_or ) ? A | B :
                 (ALUop == `ALU_slt) ? (($signed(A) < $signed(B)) ? 32'd1 : 32'd0) :
                 (ALUop == `ALU_sltu) ? ((A < B) ? 32'd1 : 32'd0) :
                 (ALUop == `ALU_addu) ? A + B :
                 (ALUop == `ALU_subu) ? A - B :
                 (ALUop == `ALU_sll ) ? B << Imm[10:6] :
                 (ALUop == `ALU_lui) ? {Imm, 16'b0} :
                 32'b0;
    assign temp = (ALUop == `ALU_add) ? {A[31], A} + {B[31], B} :
                  (ALUop == `ALU_sub) ? {A[31], A} - {B[31], B} : 33'b0;
    assign ExcCodeOut = (ExcCodeIn != 5'd0) ? ExcCodeIn :
                        (temp[32] == temp[31]) ? `Int :
                        (Instr_type == `type_CalOv) ? `Ov :
                        (Instr_type == `type_Load) ? `AdEL :
                        (Instr_type == `type_Store) ? `AdES :
                        `Int ;
endmodule

module multiply_divide (
    input wire clk, reset, start,
    input wire [2:0] Op,
    input wire [31:0] D1, D2,
    input wire Req,
    output wire busy, 
    output reg [31:0] LO, HI
);
    reg [4:0] busy_cnt;

    assign busy = (busy_cnt != `busy_zero) || (start && !Req);
    always @(posedge clk) begin
        if(reset) begin
            busy_cnt <= `busy_zero;
        end else if(start && !Req) begin
            if(Op == `MD_mult || Op == `MD_multu)
                busy_cnt <= `busy_mult;
            else if(Op == `MD_div || Op == `MD_divu)
                busy_cnt <= `busy_div;
            else
                busy_cnt <= `busy_zero;
        end else if((Op == `MD_mthi || Op == `MD_mtlo) && !Req) begin
            busy_cnt <= `busy_zero;
        end else if(busy_cnt != `busy_zero) begin
            busy_cnt <= busy_cnt - 5'd1;
        end else
            busy_cnt <= `busy_zero;
    end
    wire [32:0] divu_d, divu_r;
    assign divu_d = (D2 == 32'd0) ? LO : ({1'd0, D1} / {1'd0, D2});
    assign divu_r = (D2 == 32'd0) ? HI : ({1'd0, D1} % {1'd0, D2});
    always @(posedge clk ) begin
        if(reset) begin
            LO <= 32'd0;
            HI <= 32'd0;
        end else if(Req) begin
            LO <= LO;
            HI <= HI;
        end else if(start) begin
            case (Op)
                `MD_mult  : 
                    {HI, LO} <= {{32{D1[31]}}, D1} * {{32{D2[31]}}, D2};
                `MD_multu :
                    {HI, LO} <= {32'd0, D1} * {32'd0, D2};
                `MD_div   :
                    {HI, LO} <= (D2 == 32'd0) ? {HI, LO} : {$signed(D1) % $signed(D2), $signed(D1) / $signed(D2)};
                `MD_divu  :
                    {HI, LO} <= {divu_r[31:0], divu_d[31:0]};
                default : begin
                    LO <= LO;
                    HI <= HI;
                end
            endcase
        end else if(busy_cnt != `busy_zero) begin
            LO <= LO;
            HI <= HI;
        end else  begin
            case (Op)
                `MD_mfhi : begin
                    LO <= LO;
                    HI <= HI;
                end
                `MD_mflo : begin
                    LO <= LO;
                    HI <= HI;
                end
                `MD_mthi : begin
                    LO <= LO;
                    HI <= D1;
                end
                `MD_mtlo : begin
                    LO <= D1;
                    HI <= HI;
                end
                default : begin
                    LO <= LO;
                    HI <= HI;
                end
            endcase
        end
    end
endmodule //ALU