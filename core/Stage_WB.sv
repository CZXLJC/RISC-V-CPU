`timescale 1ns / 1ps

`include "Const.svh"
module Stage_WB(
    // 输入信号
    input  logic        MemtoReg,       // 数据选择控制
    input  logic [`DATA_WID] ALUResult,     // ALU计算结果
    input  logic [`DATA_WID] mem_rdata,      // 内存读取数据
    // 前递信号
    input  logic        Forward_wb,     // 前递控制信号，表示是否需要前递数据
    input  logic [`DATA_WID] Forward_data_wb, // 前递数据A
    // 输出信号
    output logic [`DATA_WID] wb_data         // 写回寄存器的数据
);
    // assign wb_data = MemtoReg ? mem_rdata : ALUResult;
    always_comb begin
        if (Forward_wb) begin
            wb_data = Forward_data_wb; // 前递数据
        end else begin
            wb_data = MemtoReg ? mem_rdata : ALUResult; // 选择数据源
        end
    end
endmodule