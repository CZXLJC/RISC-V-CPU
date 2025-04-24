`timescale 1ns / 1ps

`include "Const.svh"
module BranchPredictor(
    input  logic        clk,           // 时钟信号
    input  logic        rst_n,         // 复位信号
    input  logic [`DATA_WID] pc,           // 当前PC值
    input  logic [`DATA_WID] inst,         // 当前指令
    input  logic        branch_actual_taken, // 实际分支是否发生
    input  logic [`DATA_WID] branch_actual_target, // 实际分支目标地址
    input  logic [`DATA_WID] old_pc,     // 上一个PC值（用于预测）
    output logic [`DATA_WID] old_target, // 上一个预测的目标地址
    output logic [`DATA_WID] old_predict_target, // 上一个预测的目标地址
    output logic        old_actual_taken, // 上一个实际分支是否发生
    output logic        old_predict_taken, // 上一个预测的分支是否发生
    output logic        predict_taken,// 预测分支是否发生
    output logic [`DATA_WID] target_addr   // 预测的目标地址
);
    // 静态预测：总是预测分支不发生（默认顺序执行）
    assign predict_taken = 1'b0;
    assign target_addr   = pc + 32'd4; // 无效值（实际未被使用）
endmodule