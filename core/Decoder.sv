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
    output logic [3:0] ALUControl,
    output logic [2:0] BLUControl
    );
    logic [6:0] opcode;
    logic [4:0] rs1, rs2, rd;
    logic funct7;
    logic [2:0] funct3;
    logic [1:0] ALUOp;
    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign funct7 = instruction[30];
    assign funct3 = instruction[14:12];
    
    Controller u_Controller (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .Branch(Branch),
        .Jump(Jump),
        .isJalr(isJalr),
        .isAuipc(isAuipc),
        .ALUSrc(ALUSrc),
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
endmodule
