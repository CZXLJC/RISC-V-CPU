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
    // input logic mem_clk, // 这个后续可能需要用到
    input logic clk,
    input logic rst_n
);
    logic program_on; // 这个信号保证了指令与pc的同步
    logic [31:0] instruction;
    logic [31:0] instruction_temp;
    logic [31:0] old_pc;
    logic [31:0] pc;
    logic [31:0] pc_next;
    logic [31:0] writeData;
    logic [31:0] rdata1, rdata2;
    logic [31:0] imm32;
    logic MemWrite, MemtoReg, MemRead, Branch, ALUSrc, RegWrite;
    logic Jump;
    logic isJalr;
    logic isAuipc;
    logic [3:0] ALUControl;
    logic [2:0] BLUControl;
    
    logic [31:0] A, B;
    logic [31:0] ALUResult;
    logic BranchTaken;
    logic [31:0] BranchTarget;
    // logic Zero;
    assign A = (isAuipc) ? old_pc : rdata1;
    assign B = (ALUSrc) ? imm32 : rdata2;

    logic [31:0] MemReadData;

    
    assign instruction = program_on ? instruction_temp : 32'b0;
    // assign writeData = (MemtoReg) ? MemReadData : ALUResult;
    always_comb begin
        if (Jump) begin
            writeData = old_pc + 4;
        end else begin
            writeData = (MemtoReg) ? MemReadData : ALUResult;
        end
    end

    InstructionMem u_InstructionMem(
        .clka(clk),
        .addra(pc>>2),
        .douta(instruction_temp)
    );

    DataMem u_DataMem(
        // .clka(mem_clk),
        .clka(clk),
        // .ena(MemRead),
        .wea(MemWrite),
        .addra(ALUResult>>2),
        .dina(rdata2),
        .douta(MemReadData)
    );

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
        .isJalr(isJalr),
        .isAuipc(isAuipc),
        .ALUControl(ALUControl),
        .BLUControl(BLUControl)
    );

    ALU u_ALU(
        .ALUControl(ALUControl),
        .A(A),
        .B(B),
        .ALUResult(ALUResult)
    );

    BRU u_BRU(
        .BRUControl(BLUControl),
        .ALUResult(ALUResult),
        .Branch(Branch),
        .Jump(Jump),
        .isJalr(isJalr),
        .imm32(imm32),
        .pc(old_pc),
        .BranchTaken(BranchTaken),
        .BranchTarget(BranchTarget)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            old_pc <= 32'b0;
            pc <= 32'b0;
            program_on <= 1'b0;
        end else begin
            program_on <= 1'b1;
            if (BranchTaken) begin
                pc <= BranchTarget;
            end else begin
                pc <= pc + 4;
            end
            old_pc <= pc;
        end
    end
endmodule
