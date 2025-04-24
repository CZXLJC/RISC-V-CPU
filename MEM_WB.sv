`timescale 1ns / 1ps

`include "Const.svh"
module MEM_WB(
    input  logic        clk,
    input  logic        rst_n,
    // 来自MEM阶段的控制信号
    input  logic        RegWrite_in,
    input  logic        MemtoReg_in,
    // 来自MEM阶段的数据信号
    input  logic [`DATA_WID] ALUResult_in,
    input  logic [`DATA_WID] mem_rdata_in,
    input  logic [4:0]  rd_in,
    // 前递信号
    input  logic        Forward_wb, // 前递控制信号，表示是否需要前递数据
    input  logic [`DATA_WID] Forward_data_wb, // 前递数据A
    // 输出到WB阶段的信号
    output logic        RegWrite_out,
    output logic        MemtoReg_out,
    output logic [`DATA_WID] ALUResult_out,
    output logic [`DATA_WID] mem_rdata_out,
    output logic [4:0]  rd_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            RegWrite_out   <= 1'b0;
            MemtoReg_out   <= 1'b0;
            ALUResult_out <= 32'b0;
            mem_rdata_out <= 32'b0;
            rd_out        <= 5'b0;
        end else begin
            RegWrite_out   <= RegWrite_in;
            MemtoReg_out   <= MemtoReg_in;
            ALUResult_out <= ALUResult_in;
            mem_rdata_out <= mem_rdata_in;
            rd_out        <= rd_in;
        end
    end
endmodule
