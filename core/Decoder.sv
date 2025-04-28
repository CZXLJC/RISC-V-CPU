`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/16 07:20:49
// Design Name: 
// Module Name: Decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Decoder(
    input logic clk,
    input logic rst_n,
    input logic flush,
    input logic stall,
    input logic [31:0] instruction,
    input logic [31:0] writeData,
    output logic [31:0] rdata1,
    output logic [31:0] rdata2,
    output logic [31:0] imm32,
    output logic MemWrite,
    output logic MemtoReg,
    output logic MemRead,
    output logic Branch,
    output logic ALUSrc,
    output logic RegWrite,
    output logic Jump,
    output logic isJalr,
    output logic isAuipc,
    output logic ecall, 
    output logic ebreak,
    output logic mret,
    output logic [3:0] ALUControl,
    output logic [2:0] BLUControl,
    output logic [2:0] MEMControl
    );
    logic [6:0] opcode;
    logic [4:0] rs1, rs2, rd;
    logic funct7;
    logic [2:0] funct3;
    logic [11:0] funct12;
    logic [1:0] ALUOp;
    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign funct7 = instruction[30];
    assign funct3 = instruction[14:12];
    assign funct12 = instruction[31:20];


    logic MemWrite_temp;
    logic MemtoReg_temp;
    logic MemRead_temp;
    logic Branch_temp;
    logic ALUSrc_temp;
    logic RegWrite_temp;
    logic Jump_temp;
    logic isJalr_temp;
    logic isAuipc_temp;
    assign MemWrite = (flush) ? 1'b0 : MemWrite_temp;
    assign MemtoReg = (flush) ? 1'b0 : MemtoReg_temp;
    assign MemRead = (flush) ? 1'b0 : MemRead_temp;
    assign Branch = (flush) ? 1'b0 : Branch_temp;
    assign ALUSrc = (flush) ? 1'b0 : ALUSrc_temp;
    assign RegWrite = (flush) ? 1'b0 : RegWrite_temp;
    assign Jump = (flush) ? 1'b0 : Jump_temp;
    assign isJalr = (flush) ? 1'b0 : isJalr_temp;
    assign isAuipc = (flush) ? 1'b0 : isAuipc_temp;
    
    Controller u_Controller (
        .opcode(opcode),
        .funct12(funct12),
        .RegWrite(RegWrite_temp),
        .MemWrite(MemWrite_temp),
        .MemRead(MemRead_temp),
        .MemtoReg(MemtoReg_temp),
        .Branch(Branch_temp),
        .Jump(Jump_temp),
        .isJalr(isJalr_temp),
        .isAuipc(isAuipc_temp),
        .ALUSrc(ALUSrc_temp),
        .ecall(ecall),
        .ebreak(ebreak),
        .mret(mret),
        // .MemWrite(MemWrite),
        // .MemRead(MemRead),
        // .MemtoReg(MemtoReg),
        // .Branch(Branch),
        // .Jump(Jump),
        // .isJalr(isJalr),
        // .isAuipc(isAuipc),
        // .ALUSrc(ALUSrc),
        .ALUOp(ALUOp)
    );
    Registers u_Registers (
        .clk(clk),
        .rst_n(rst_n),
        .RegWrite(RegWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .writeData(writeData),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );
    ImmGen u_ImmGen (
        .instruction(instruction),
        .imm32(imm32)
    );
    ALUController u_ALUControl (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );
    assign BLUControl = funct3;
    assign MEMControl = funct3;
endmodule
