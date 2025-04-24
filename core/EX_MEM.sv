`timescale 1ns / 1ps

`include "Const.svh"
module EX_MEM(
    input  logic        clk,
    input  logic        rst_n,
    // 来自EX阶段的控制信号
    input  logic        RegWrite_in,
    input  logic        MemWrite_in,
    input  logic        MemRead_in,
    input  logic        MemtoReg_in,
    // 来自EX阶段的数据信号
    input  logic [`DATA_WID] ALUResult_in,
    input  logic [`DATA_WID] rdata2_in,
    input  logic [`REG_ID_WID]  rd_in,
    // 输出到MEM阶段的信号
    output logic        RegWrite_out,
    output logic        MemWrite_out,
    output logic        MemRead_out,
    output logic        MemtoReg_out,
    output logic [`DATA_WID] ALUResult_out,
    output logic [`DATA_WID] rdata2_out,
    output logic [`REG_ID_WID]  rd_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            RegWrite_out   <= 1'b0;
            MemWrite_out   <= 1'b0;
            MemRead_out    <= 1'b0;
            MemtoReg_out   <= 1'b0;
            ALUResult_out <= 32'b0;
            rdata2_out     <= 32'b0;
            rd_out        <= 5'b0;
        end else begin
            RegWrite_out   <= RegWrite_in;
            MemWrite_out   <= MemWrite_in;
            MemRead_out    <= MemRead_in;
            MemtoReg_out   <= MemtoReg_in;
            ALUResult_out <= ALUResult_in;
            rdata2_out     <= rdata2_in;
            rd_out        <= rd_in;
        end
    end
endmodule