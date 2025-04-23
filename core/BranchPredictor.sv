`timescale 1ns / 1ps

module BranchPredictor(
    input  logic        clk,           // 时钟信号
    input  logic        rst_n,         // 复位信号
    input  logic [31:0] pc,           // 当前PC值
    input  logic [31:0] inst,         // 当前指令
    input  logic        branch_actual_taken, // 实际分支是否发生
    input  logic [31:0] branch_actual_target, // 实际分支目标地址
    input  logic [31:0] old_pc,     // 上一个PC值（用于预测）
    output logic [31:0] old_target, // 上一个预测的目标地址
    output logic [31:0] old_predict_target, // 上一个预测的目标地址
    output logic        old_actual_taken, // 上一个实际分支是否发生
    output logic        old_predict_taken, // 上一个预测的分支是否发生
    output logic        predict_taken,// 预测分支是否发生
    output logic [31:0] target_addr   // 预测的目标地址
);
    // 静态预测：总是预测分支不发生（默认顺序执行）
    assign predict_taken = 1'b0;
    assign target_addr   = pc + 32'd4; // 无效值（实际未被使用）

    // 可扩展为动态预测（如基于历史位的分支目标缓冲BTB）

    // parameter BTB_SIZE = 64;
    // typedef struct packed {
    //     logic [31:0] tag;         // 分支指令的高位地址
    //     logic [31:0] target;      // 分支目标地址
    //     logic        valid;       // 有效位
    // } btb_entry_t;

    // // BHT 条目定义（2位饱和计数器）
    // typedef logic [1:0] bht_entry_t;

    // // 存储器实例化
    // btb_entry_t BTB [0:BTB_SIZE-1];
    // bht_entry_t BHT [0:BTB_SIZE-1];

    // logic [5:0] index; // BTB索引
    // assign index = pc[7:2];

    // // 预测逻辑
    // always_ff @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         foreach (BTB[i]) begin
    //             BTB[i].valid <= 1'b0;
    //             BHT[i] <= 2'b01;  // 初始状态：弱不跳转
    //         end
    //     end else begin
    //         // 更新BHT（实际分支结果反馈）
    //         if (inst[6:0] == 7'b1100011) begin  // 分支指令
    //             case (BHT[index])
    //                 2'b00: BHT[index] <= branch_actual_taken ? 2'b01 : 2'b00;
    //                 2'b01: BHT[index] <= branch_actual_taken ? 2'b10 : 2'b00;
    //                 2'b10: BHT[index] <= branch_actual_taken ? 2'b11 : 2'b01;
    //                 2'b11: BHT[index] <= branch_actual_taken ? 2'b11 : 2'b10;
    //             endcase

    //             // 更新BTB
    //             if (branch_actual_taken) begin
    //                 BTB[index].tag <= pc[31:8];
    //                 BTB[index].target <= branch_actual_target;
    //                 BTB[index].valid <= 1'b1;
    //             end
    //         end
    //     end
    // end

    // // 预测输出
    // assign predict_taken = (BHT[index][1] == 1'b1) && (BTB[index].valid && (BTB[index].tag == pc[31:8]));
    // assign target_addr = BTB[index].valid ? BTB[index].target : pc + 32'd4; // 默认顺序执行
endmodule