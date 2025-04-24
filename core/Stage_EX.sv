`timescale 1ns / 1ps

`include "Const.svh"
module Stage_EX(
    input  logic [`DATA_WID] forward_data_ex_mem,  // EX/MEM阶段前递数据
    input  logic [`DATA_WID] forward_data_mem_wb,  // MEM/WB阶段前递数据
    input  logic [1:0]  ForwardA,             // rs1前递选择
    input  logic [1:0]  ForwardB,              // rs2前递选择

    input  logic [`DATA_WID] pc_curr_ex,     // 当前PC值
    input  logic [`ALUCONTROL_WIDTH]  ALUControl,   // ALU操作码
    input  logic [`BRUCONTROL_WIDTH]  BRUControl,    // 分支控制信号
    input  logic [`DATA_WID] rdata1,       // 寄存器1数据
    input  logic [`DATA_WID] rdata2,       // 寄存器2数据
    input  logic [`DATA_WID] imm32,        // 立即数
    input  logic        ALUSrc,       // ALU操作数选择
    input  logic        Branch,       // 分支指令标志
    input  logic        Jump,         // 跳转指令标志
    output logic [`DATA_WID] ALUResult,    // ALU计算结果
    output logic [`DATA_WID] BranchTarget,  // 分支目标地址
    output logic        BranchTaken   // 分支发生标志
);
    logic [`DATA_WID] operand1;
    logic [`DATA_WID] operand2;
    
    // 前递逻辑处理
    always_comb begin
        // 前递数据选择
        case (ForwardA)
            2'b00: operand1 = rdata1; // 无前递
            2'b01: operand1 = forward_data_ex_mem; // EX/MEM前递
            2'b10: operand1 = forward_data_mem_wb; // MEM/WB前递
            default: operand1 = rdata1; // 默认值
        endcase
        if (ALUSrc) begin
            operand2 = imm32;
        end else begin
           case (ForwardB)
            2'b00: operand2 = rdata2; // 无前递
            2'b01: operand2 = forward_data_ex_mem; // EX/MEM前递
            2'b10: operand2 = forward_data_mem_wb; // MEM/WB前递
            default: operand2 = rdata2; // 默认值
           endcase 
        end
    end

    // ALU实例化    
    ALU u_ALU (
        .A(operand1),
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
        .pc_curr_ex(pc_curr_ex),
        .imm32(imm32),
        .BranchTaken(BranchTaken),
        .BranchTarget(BranchTarget)
    );
    
endmodule
