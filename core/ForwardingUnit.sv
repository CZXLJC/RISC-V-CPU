`timescale 1ns / 1ps


`include "Const.svh"
// 处理写入后的执行冲突，用于前递
module ForwardingUnit(
    // 来自ID阶段的源寄存器
    input  logic [`REG_ID_WID] rs1_ex,
    input  logic [`REG_ID_WID] rs2_ex,
    // 来自EX/MEM和MEM/WB阶段的目标寄存器
    input  logic [`REG_ID_WID] rd_ex_mem,
    input  logic       RegWrite_ex_mem,
    input  logic [`REG_ID_WID] rd_mem_wb,
    input  logic       RegWrite_mem_wb,
    // 前递控制信号，前递到ID/EX阶段
    output logic [1:0] ForwardA,  // 00: 无前递，01: EX/MEM前递，10: MEM/WB前递
    output logic [1:0] ForwardB
);
    always_comb begin
        // ForwardA逻辑（rs1前递）
        // 当前EX/MEM阶段指令需要执行写入的寄存器与ID阶段的rs1相同（即需要在下一条指令用到），将EX/MEM阶段的结果前递到ID阶段
        if (RegWrite_ex_mem && (rd_ex_mem != 0) && (rd_ex_mem == rs1_ex)) 
            ForwardA = 2'b01;  // 前递EX/MEM阶段的结果
        else if (RegWrite_mem_wb && (rd_mem_wb != 0) && (rd_mem_wb == rs1_ex)) 
        // 当前MEM/WB阶段指令需要执行写入的寄存器与ID阶段的rs1相同，将MEM/WB阶段的结果前递到ID阶段
            ForwardA = 2'b10;  // 前递MEM/WB阶段的结果
        else 
            ForwardA = 2'b00;  // 无前递

        // ForwardB逻辑（rs2前递）
        if (RegWrite_ex_mem && (rd_ex_mem != 0) && (rd_ex_mem == rs2_ex)) 
            ForwardB = 2'b01;
        else if (RegWrite_mem_wb && (rd_mem_wb != 0) && (rd_mem_wb == rs2_ex)) 
            ForwardB = 2'b10;
        else 
            ForwardB = 2'b00;
    end
endmodule