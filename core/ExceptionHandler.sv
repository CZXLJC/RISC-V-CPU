`timescale 1ns / 1ps

module ExceptionHandler(
    input  logic clk,
    input  logic rst_n,
    input  logic [31:0] pc,           // 当前指令地址
    input  logic [31:0] inst,         // 当前指令
    input  logic opecodeException, // 操作码异常
    input  logic ecall,              // 系统调用
    input  logic ebreak,             // 断点异常
    output logic exception,         // 异常信号
    output logic [31:0] pc_out,     // 回写的PC
    output logic [31:0] handler_pc
);
    // assign exception = opecodeException || ecall || ebreak;
    assign exception = ecall || ebreak;

    CSR u_csr(
        .clk(clk),
        .rst_n(rst_n),
        .pc(pc),
        .ecall_en(ecall),
        .csr_rdata(pc_out),
        // .exception(exception),
        .handler_pc(handler_pc)
    );
   
endmodule