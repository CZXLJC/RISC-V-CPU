`timescale 1ns / 1ps

module InterruptController(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        ext_irq,     // 外部中断信号
    input  logic [31:0] mepc,        // 异常返回地址（CSR）
    output logic        irq_taken,   // 中断发生标志
    output logic [31:0] handler_pc   // 中断处理入口
);
    // 简单实现：中断优先级固定，入口地址固定
    assign irq_taken = ext_irq && (mepc != 32'h0);  // 假设中断已使能
    assign handler_pc = 32'h80000100;              // 中断处理入口
endmodule

module CSRegisters(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        exception,
    input  logic [31:0] epc,         // 异常PC
    output logic [31:0] mepc,        // 机器异常PC
    output logic [31:0] mstatus      // 机器状态
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mepc <= 32'b0;
            mstatus <= 32'b0;
        end else if (exception) begin
            mepc <= epc;            // 保存异常PC
            mstatus <= {mstatus[31:8], 1'b1, mstatus[6:0]}; // 设置中断使能位
        end
    end
endmodule