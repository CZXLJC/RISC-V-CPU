`timescale 1ns / 1ps

module ExceptionHandler(
    input  logic [31:0] pc,           // 当前指令地址
    input  logic [31:0] inst,         // 当前指令
    input  logic [31:0] mem_addr,     // 内存访问地址
    input  logic        mem_write,    // 内存写操作
    input  logic        mem_read,     // 内存读操作
    output logic        exception,    // 异常标志
    output logic [31:0] handler_pc    // 异常处理程序入口地址
);
    // 检测非法指令（假设opcode不在支持列表中）
    logic illegal_inst;
    assign illegal_inst = !(inst[6:0] inside {
        7'b0000011, // LOAD
        7'b0100011, // STORE
        7'b1100011, // BRANCH
        7'b0110011, // R-type
        7'b0010011, // I-type
        7'b1100111, // JALR
        7'b1101111, // JAL
        7'b0110111, // LUI
        7'b0010111  // AUIPC
    });

    // 检测内存未对齐访问（假设LW/SW地址需4字节对齐）
    logic mem_misalign;
    assign mem_misalign = (mem_read || mem_write) && (mem_addr[1:0] != 2'b00);

    // 触发异常条件
    assign exception = illegal_inst || mem_misalign;
    assign handler_pc = 32'h80000000; // 异常处理程序入口
endmodule