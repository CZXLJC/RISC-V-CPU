`timescale 1ns / 1ps

`include "Const.svh"
module ID_EX(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        Flush,
    // 来自ID阶段的控制信号
    input  logic [`ALUCONTROL_WIDTH]  ALUControl_in,
    input  logic        RegWrite_in,
    input  logic        MemWrite_in,
    input  logic        MemRead_in,
    input  logic        MemtoReg_in,
    input  logic        ALUSrc_in,
    // 来自ID阶段的数据信号
    input  logic [31:0] imm32_in,
    input  logic [31:0] rdata1_in,
    input  logic [31:0] rdata2_in,
    input  logic [4:0]  rd_in,
    // 输出到EX阶段的信号
    output logic [`ALUCONTROL_WIDTH]  ALUControl_out,
    output logic        RegWrite_out,
    output logic        MemWrite_out,
    output logic        MemRead_out,
    output logic        MemtoReg_out,
    output logic        ALUSrc_out,
    output logic [31:0] imm32_out,
    output logic [31:0] rdata1_out,
    output logic [31:0] rdata2_out,
    output logic [4:0]  rd_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || Flush) begin
            ALUControl_out <= 5'b0;
            RegWrite_out   <= 1'b0;
            MemWrite_out   <= 1'b0;
            MemRead_out    <= 1'b0;
            MemtoReg_out   <= 1'b0;
            ALUSrc_out     <= 1'b0;
            imm32_out      <= 32'b0;
            rdata1_out     <= 32'b0;
            rdata2_out     <= 32'b0;
            rd_out         <= 5'b0;
        end else begin
            ALUControl_out <= ALUControl_in;
            RegWrite_out   <= RegWrite_in;
            MemWrite_out   <= MemWrite_in;
            MemRead_out    <= MemRead_in;
            MemtoReg_out   <= MemtoReg_in;
            ALUSrc_out     <= ALUSrc_in;
            imm32_out      <= imm32_in;
            rdata1_out     <= rdata1_in;
            rdata2_out     <= rdata2_in;
            rd_out         <= rd_in;
        end
    end
endmodule