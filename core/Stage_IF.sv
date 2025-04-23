`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/18 07:29:51
// Design Name: 
// Module Name: Stage_IF
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Stage_IF(
    // 基础信号
    input  logic        clk,          // 时钟
    input  logic        rst_n,        // 复位（低有效）
    // 控制信号
    input  logic        BranchTaken,  // 分支发生信号（来自ID阶段）
    input  logic [31:0] BranchTarget, // 分支目标地址（来自ID阶段）
    input  logic        Stall,        // 流水线阻塞信号（来自冒险检测）


    // old预测和分支相关信号
    input  logic [31:0] old_pc, old_target, old_predict_target,
    input  logic        old_predict_taken, old_actual_taken,

    // 输出信号
    output logic [31:0] pc_curr,   // 当前PC值
    output logic [31:0] inst,  // 取到的指令
    output logic [31:0] pc_plus4,      // PC+4（传递给下一阶段）
    // 分支预测相关信号
    output logic predict_taken, // 预测的分支是否发生
    output logic [31:0] predict_pc
    // , // 预测的目标地址
    // output logic predict_fail // 预测失败信号
);
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
        .addra(pc_curr[13:0]>>2),  // 地址位宽为14位（16KB空间）
        .douta(inst)
    );

    // 计算PC+4（默认下一条指令地址）
    assign pc_plus4 = pc_curr + 32'd4;

    // 确定下一个PC值
    always_comb begin
        if (BranchTaken)
            pc_next = BranchTarget;   // 分支跳转
        else if (Stall) begin
            pc_next = pc_curr;       // 流水线阻塞时，PC保持不变
            // if (pc_curr < 32'h8) begin
            //     pc_next = 32'h00000000; // 防止PC溢出
            // end else begin
            //     pc_next = pc_curr - 32'h8; // 流水线阻塞时，PC保持不变
            // end
        end
        else
            // pc_next = pc_plus4;       // 默认递增
            pc_next = predict_pc;      // 使用预测的PC值
    end

    // PC寄存器更新（同步复位）
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc_curr <= 32'h00000000;  // 复位时PC初始化为0
        else 
            pc_curr <= pc_next;       // 更新PC
    end

    // PC u_PC (
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .new_pc(pc_next),
    //     .pc_curr(pc_curr)
    // );
endmodule
