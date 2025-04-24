`timescale 1ns / 1ps

`include "Const.svh"
module Stage_IF #(
    parameter limit = 32'b10000000
)(
    // 基础信号
    input  logic        clk,          // 时钟
    input  logic        rst_n,        // 复位（低有效）
    // 控制信号
    input  logic        BranchTaken,  // 分支发生信号（来自ID阶段）
    input  logic [31:0] BranchTarget, // 分支目标地址（来自ID阶段）
    input  logic        Stall,        // 流水线阻塞信号（来自冒险检测）
    // old预测和分支相关信号
    input  logic [31:0] old_target, old_predict_target,
    input  logic        old_predict_taken, old_actual_taken,

    // 输出信号
    output logic [31:0] old_pc,
    output logic [31:0] pc_curr,   // 当前PC值
    output logic [31:0] inst,  // 取到的指令
    output logic predict_taken, // 预测的分支是否发生
    output logic [31:0] predict_pc
);

    logic program_on;
    logic [31:0] inst_temp;
    assign program_on = rst_n;
    assign inst = program_on ? inst_temp : 32'b0;

    logic [31:0] pc_next; // 下一个PC值

    BranchPredictor u_BranchPredictor (
        .clk(clk),
        .rst_n(rst_n),
        .pc(pc_curr),
        .inst(inst),
        .predict_taken(predict_taken),
        .target_addr(predict_pc),
        .branch_actual_taken(BranchTaken),
        .branch_actual_target(BranchTarget),
        .old_pc(old_pc),
        .old_target(old_target),
        .old_predict_target(old_predict_target),
        .old_predict_taken(old_predict_taken),
        .old_actual_taken(old_actual_taken)
    );

    // 指令存储器实例化（假设已存在）
    InstructionMem u_InstructionMem (
        .clka(clk),
        .addra(pc_curr[15:2]),  // 地址位宽为14位（16KB空间）
        .douta(inst_temp)
    );
    

    always_comb begin
        if (BranchTaken)
            pc_next = BranchTarget;   // 分支跳转
        else if (Stall) begin
            pc_next = old_pc;      // 流水线阻塞，保持当前PC不变
        end else
            pc_next = predict_pc;      // 使用预测的PC值
    end

    // PC寄存器更新（同步复位）
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            old_pc <= 32'h00000000; // 复位时PC初始化为0
            pc_curr <= 32'h00000000;  // 复位时PC初始化为0
        end
        else
            if (pc_curr >= limit) begin
                pc_curr <= pc_curr; // 中止程序
            end else begin
                pc_curr <= pc_next;  // 更新PC
            end
            old_pc <= pc_curr; // 更新old_pc
    end

endmodule
