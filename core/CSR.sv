`timescale 1ns / 1ps

`include "Const.svh"

module CSR (
    input  logic        clk,
    input  logic        rst_n,
    
    // 异常接口
    input  logic [31:0] pc, // 当前PC（用于mepc）
    input  logic        ecall_en,    // ecall触发信号
    // output logic        exception,  // 异常触发信号
    output logic [31:0] handler_pc,   // 异常处理程序入口

    // CSR 接口
    // input  logic [11:0] csr_addr,   // CSR 地址
    // input  logic        csr_wr_en,  // 写使能
    // input  logic [31:0] csr_wdata,  // 写数据
    output logic [31:0] csr_rdata  // 读数据
);
    // CSR 定义
typedef enum logic [11:0] {
    CSR_MSTATUS  = 12'h300,
    CSR_MEPC     = 12'h341,
    CSR_MCAUSE   = 12'h342
} csr_addr_e;

// 寄存器声明
logic [31:0] mstatus;
logic [31:0] mepc;
logic [31:0] mcause;

// CSR 写操作
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // mstatus <= 32'h0;
        mepc    <= 32'h0;
        mcause  <= 32'h0;
    end else begin
        // if (csr_wr_en) begin
        //     case (csr_addr)
        //         CSR_MSTATUS: mstatus <= csr_wdata;
        //         CSR_MEPC:    mepc    <= csr_wdata;
        //         CSR_MCAUSE: mcause  <= csr_wdata;
        //     endcase
        // end
        
        // ecall 处理
        if (ecall_en) begin
            mepc   <= pc;      // 保存当前PC
            mcause <= 32'hB;           // 设置异常原因（ecall编码）
            mstatus <= {mstatus[31:13], 2'b11, mstatus[10:0]}; // 更新mstatus（示例：切换模式）
        end
    end
end

// CSR 读操作
// always_comb begin
//     case (csr_addr)
//         // CSR_MSTATUS: csr_rdata = mstatus;
//         CSR_MEPC:    csr_rdata = mepc;
//         CSR_MCAUSE:  csr_rdata = mcause;
//         default:     csr_rdata = 32'h0;
//     endcase
// end

always_comb begin
    handler_pc = 32'h0;
    if (ecall_en) begin
        handler_pc = 32'h0000_0010;
    end
end

assign csr_rdata = mepc; // 默认读出mepc寄存器的值
endmodule