`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/16 08:59:13
// Design Name: 
// Module Name: CPU
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


module CPU(
    input logic clk,
    input logic rst_n,
    // input logic [13:0] pc,
    input logic [31:0] instruction
);
    logic [13:0] pc;
    logic [31:0] writeData;
    logic [31:0] rdata1, rdata2;
    logic [31:0] imm32;
    logic MemWrite, MemtoReg, MemRead, Branch, ALUSrc, RegWrite;
    logic Jump;
    logic [3:0] ALUControl;
    logic [1:0] BLUControl;
    
    logic [31:0] A, B;
    logic [31:0] ALUResult;
    logic BranchTaken;
    logic [31:0] BranchTarget;
    // logic Zero;
    assign A = rdata1;
    assign B = (ALUSrc) ? imm32 : rdata2;

    logic [31:0] MemReadData;

    assign writeData = (MemtoReg) ? MemReadData : ALUResult;

    Decoder u_Decoder(
        .clk(clk),
        .rst_n(rst_n),
        .instruction(instruction),
        .writeData(writeData),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .imm32(imm32),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .MemRead(MemRead),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .ALUControl(ALUControl)
    );

    ALU u_ALU(
        .ALUControl(ALUControl),
        .A(A),
        .B(B),
        .ALUResult(ALUResult)
        // ,
        // .Zero(Zero)
    );

    BRU u_BRU(
        .BRUControl(BLUControl),
        .ALUResult(ALUResult),
        .Branch(Branch),
        .Jump(Jump),
        .imm32(imm32),
        .pc(pc),
        .BranchTaken(BranchTaken),
        .BranchTarget(BranchTarget)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 0;
        end else begin
            if (Branch && BranchTaken) begin
                pc <= pc + imm32;
            end else begin
                pc <= pc + 4;
            end
        end
    end
endmodule
