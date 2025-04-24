`timescale 1ns / 1ps

module Stage_MEM(
    // 控制信号
    input  logic        MemWrite,    // 存储器写使能
    input  logic        MemRead,     // 存储器读使能
    // 数据信号
    input  logic [31:0] ALUResult,  // 内存地址（来自ALU结果）
    input  logic [31:0] rdata2,      // 存储数据（来自寄存器）

    // 前递信号
    input  logic Forward_wb, // 前递控制信号，表示是否需要前递数据
    input  logic [31:0] Forward_data_wb, // 前递数据A
    // 数据存储器接口
    output logic [31:0] mem_addr,    // 内存地址
    output logic        mem_we,      // 写使能
    output logic [31:0] mem_wdata,   // 写入数据
    input  logic [31:0] mem_rdata    // 读取数据（来自DataMem）
);
    // 直接连接信号
    assign mem_addr  = ALUResult;   // 地址为ALU计算结果
    assign mem_we    = MemWrite;     // 写使能由控制信号决定
    assign mem_wdata = rdata2;       // 写入数据来自寄存器rdata2

    // 读操作由DataMem自动完成，mem_rdata直接输入
endmodule