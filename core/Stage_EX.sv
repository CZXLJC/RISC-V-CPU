`timescale 1ns / 1ps

`include "Const.svh"
module Stage_EX(
    input  logic [`ALUCONTROL_WIDTH]  ALUControl,   // ALU操作码
    input  logic [31:0] rdata1,       // 寄存器1数据
    input  logic [31:0] rdata2,       // 寄存器2数据
    input  logic [31:0] imm32,        // 立即数
    input  logic        ALUSrc,       // ALU操作数选择
    input  logic        Branch,       // 分支指令标志
    input  logic        Jump,         // 跳转指令标志
    input  logic [2:0]  BRUControl,    // 分支控制信号
    output logic [31:0] ALUResult    // ALU计算结果
);
    logic [31:0] operand2;
    
    // 选择ALU的第二个操作数（寄存器或立即数）
    assign operand2 = ALUSrc ? imm32 : rdata2;

    // ALU实例化    
    ALU u_ALU (
        .A(rdata1),
        .B(operand2),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult)
    );

    // BRU实例化
    BRU u_BRU (
        .BRUControl(BRUControl), 
        .ALUResult(ALUResult),
        .Branch(Branch), // 暂时不使用分支信号
        .Jump(Jump),   // 暂时不使用跳转信号
        .pc(32'h00000000), // 暂时不使用PC信号
        .imm32(imm32),
        .BranchTaken(), // 暂时不使用分支结果
        .BranchTarget()  // 暂时不使用分支目标地址
    );
    
endmodule
