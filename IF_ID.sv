`timescale 1ns / 1ps


// 这个模块实现了IF/ID流水线寄存器，用于在IF阶段和ID阶段之间传递指令和PC+4值。
module IF_ID(
    input  logic        clk,          // 时钟
    input  logic        rst_n,        // 复位（低有效）
    input  logic        Stall,        // 流水线阻塞信号
    input  logic        Flush,        // 冲刷信号（来自冒险检测）
    input  logic [31:0] inst_in,      // 来自IF阶段的指令
    // input  logic [31:0] pc_plus4_in,  // 来自IF阶段的PC+4
    input  logic [31:0] pc_curr_in, 
    output logic [31:0] inst_out,     // 输出到ID阶段的指令
    // output logic [31:0] pc_plus4_out  // 输出到ID阶段的PC+4
    output logic [31:0] pc_curr_out   // 输出到ID阶段的PC+4
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || Flush) begin
            inst_out     <= 32'b0;
            pc_curr_out <= 32'b0;
        end else if (!Stall) begin
            inst_out     <= inst_in;
            pc_curr_out <= pc_curr_in;
        end else begin
            inst_out     <= inst_out; // 保持原值
            pc_curr_out <= pc_curr_out; // 保持原值
        end
    end
endmodule