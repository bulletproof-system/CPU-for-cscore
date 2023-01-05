`timescale 1ns / 1ps
`default_nettype none
`include "Gobals.v"
`ifdef IVERILOG
`include "MulDivUnit.v"
`endif

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
                 (ALUop == `ALU_srl ) ? B >> Imm[10:6] :
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
    input wire [3:0] Op,
    input wire [31:0] D1, D2,
    input wire Req,
    output wire busy, 
    output wire [31:0] LO_out, HI_out
);
    reg [31:0] LO, HI;
    always @(posedge clk) begin
        if(reset) begin
            LO <= 32'd0;
            HI <= 32'd0;
        end else begin
            if(out_valid) begin
                LO <= out_res0;
                HI <= out_res1;
            end else begin
                LO <= LO;
                HI <= HI;
            end
            if(!Req) begin
                case (Op)
                    `MD_mtlo : LO <= D1;
                    `MD_mthi : HI <= D1;
                endcase
            end
        end;
    end
    wire in_sign, in_valid, out_valid, in_ready, out_ready;
    wire [1:0] in_op;
    wire [31:0] out_res0, out_res1;

    MulDivUnit MulDivUnit(
        .clk(clk), .reset(reset),
        .in_src0(D1), .in_src1(D2),
        .in_op(in_op), .in_sign(in_sign),
        .in_valid(in_valid), .out_valid(out_valid),
        .in_ready(in_ready), .out_ready(out_ready),
        .out_res0(out_res0), .out_res1(out_res1)
    );

    assign LO_out = (out_valid) ? out_res0 : LO;
    assign HI_out = (out_valid) ? out_res1 : HI;
    assign in_sign = (Op == `MD_mult) || (Op == `MD_div);
    assign in_op = (Op == `MD_mult) || (Op == `MD_multu) ? 2'd1 :
                   (Op == `MD_div) || (Op == `MD_divu) ? 2'd2 :
                   2'd0;
    assign in_valid = (start && !Req);
    assign out_ready = (Op == `MD_mfhi) || (Op == `MD_mflo);
    assign busy = ~out_valid || (start && !Req);
endmodule //ALU