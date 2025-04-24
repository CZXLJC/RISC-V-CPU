`timescale 1ns / 1ps

`include "Const.svh"
module ID_EX(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        Stall,
    input  logic        Flush,
    input  logic [31:0] pc_curr_in,

    // 来自ID阶段的控制信号
    input  logic [`ALUCONTROL_WIDTH]  ALUControl_in,
    input  logic [`BRUCONTROL_WIDTH]  BRUControl_in,
    input  logic        RegWrite_in,
    input  logic        MemWrite_in,
    input  logic        MemRead_in,
    input  logic        MemtoReg_in,
    input  logic        ALUSrc_in,
    input  logic        Branch_in,
    input  logic        Jump_in,
    // 来自ID阶段的数据信号
    input  logic [31:0] imm32_in,
    input  logic [31:0] rdata1_in,
    input  logic [31:0] rdata2_in,
    input  logic [4:0]  rs1_in,
    input  logic [4:0]  rs2_in,
    input  logic [4:0]  rd_in,
    // 输出到EX阶段的信号
    output logic [`ALUCONTROL_WIDTH]  ALUControl_out,
    output logic [`BRUCONTROL_WIDTH]  BRUControl_out,
    output logic        RegWrite_out,
    output logic        MemWrite_out,
    output logic        MemRead_out,
    output logic        MemtoReg_out,
    output logic        ALUSrc_out,
    output logic        Branch_out,
    output logic        Jump_out,
    output logic [31:0] imm32_out,

    output logic [31:0] pc_curr_out,

    output logic [31:0] rdata1_out,
    output logic [31:0] rdata2_out,
    output logic [4:0]  rs1_out,
    output logic [4:0]  rs2_out,
    output logic [4:0]  rd_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || Flush) begin
            ALUControl_out <= 5'b0;
            BRUControl_out <= 3'b0;
            RegWrite_out   <= 1'b0;
            MemWrite_out   <= 1'b0;
            MemRead_out    <= 1'b0;
            MemtoReg_out   <= 1'b0;
            ALUSrc_out     <= 1'b0;
            Branch_out     <= 1'b0;
            Jump_out       <= 1'b0;
            imm32_out      <= 32'b0;
            rdata1_out     <= 32'b0;
            rdata2_out     <= 32'b0;
            rs1_out        <= 5'b0;
            rs2_out        <= 5'b0;
            rd_out         <= 5'b0;
            pc_curr_out    <= 32'b0;
        end else begin
            ALUControl_out <= ALUControl_in;
            BRUControl_out <= BRUControl_in;
            RegWrite_out   <= RegWrite_in;
            MemWrite_out   <= MemWrite_in;
            MemRead_out    <= MemRead_in;
            MemtoReg_out   <= MemtoReg_in;
            ALUSrc_out     <= ALUSrc_in;
            Branch_out     <= Branch_in;
            Jump_out       <= Jump_in;
            imm32_out      <= imm32_in;
            rdata1_out     <= rdata1_in;
            rdata2_out     <= rdata2_in;
            rs1_out        <= rs1_in;
            rs2_out        <= rs2_in;
            rd_out         <= rd_in;
            pc_curr_out    <= pc_curr_in; // 传递当前PC值
        end 
        // else begin
        //     ALUControl_out <= ALUControl_out;
        //     BRUControl_out <= BRUControl_out;
        //     RegWrite_out   <= RegWrite_out;
        //     MemWrite_out   <= MemWrite_out;
        //     MemRead_out    <= MemRead_out;
        //     MemtoReg_out   <= MemtoReg_out;
        //     ALUSrc_out     <= ALUSrc_out;
        //     Branch_out     <= Branch_out;
        //     Jump_out       <= Jump_out;
        //     imm32_out      <= imm32_out;
        //     rdata1_out     <= rdata1_out;
        //     rdata2_out     <= rdata2_out;
        //     rs1_out        <= rs1_out;
        //     rs2_out        <= rs2_out;
        //     rd_out         <= rd_out;
        //     pc_curr_out    <= pc_curr_out; // 传递当前PC值
        // end
    end
endmodule