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

// `include "Const.svh"
module CPU(
    input logic clk,
    input logic rst_n,
    output logic [7:0] led
);

    logic mem_clk;
    logic program_on; // 这个信号保证了指令与pc的同步
    logic [31:0] instruction;
    logic [31:0] old_pc;
    logic [31:0] pc;
    logic [31:0] pc_real;
    logic [31:0] imm32;
    logic MemWrite, MemtoReg, MemRead, Branch, ALUSrc, RegWrite;
    logic Jump;
    logic isJalr;
    logic isAuipc;
    logic       ecall, ebreak, mret;
    logic [3:0] ALUControl;
    logic [2:0] BLUControl;
    logic [2:0] MEMControl;

    logic [31:0] writeData;
    logic [31:0] rdata1, rdata2;
    logic [31:0] rdata3; // x8寄存器的值
    logic [31:0] A, B;
    logic [31:0] ALUResult;
    logic BranchTaken;
    logic [31:0] BranchTarget;
    logic [31:0] MemReadData;
    logic stall_dcache;
    logic stall_waitInput;
    logic flush;
    assign A = (isAuipc) ? old_pc : rdata1;
    assign B = (ALUSrc) ? imm32 : rdata2;
    assign led[7:0] = rdata3[7:0];

    always_comb begin
        if (Jump) begin
            writeData = old_pc + 4;
        end else begin
            writeData = (MemtoReg) ? MemReadData : ALUResult;
        end
    end

    logic exception;
    logic [31:0] handler_pc;
    logic [31:0] csr_pc;

    InstructionMem u_InstructionMem(
        .clka(clk),
        // 读使能
        .ena(program_on),
        .addra(pc_real>>2),
        .douta(instruction)
    );

    DCache u_DCache(
        .clk(clk),
        .rst_n(rst_n),
        .addr(ALUResult>>2),
        .data_write(rdata2),
        .data_read(MemReadData),
        .MEMControl(MEMControl),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .stall_dcache(stall_dcache)
    );

    Decoder u_Decoder(
        .clk(clk),
        .rst_n(rst_n),
        .stall(1'b0),
        .flush(flush),
        .instruction(instruction),
        .writeData(writeData),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .rdata3(rdata3),
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
        .ecall(ecall),
        .ebreak(ebreak),
        .mret(mret),
        .ALUControl(ALUControl),
        .BLUControl(BLUControl),
        .MEMControl(MEMControl)
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

    ExceptionHandler u_ExceptionHandler(
        .clk(clk),
        .rst_n(rst_n),
        .pc(pc),
        .inst(instruction),
        // .opecodeException(1'b0), // 这里需要连接到操作码异常信号
        .ecall(ecall),
        .ebreak(ebreak),
        .exception(exception),
        .handler_pc(handler_pc),
        .pc_out(csr_pc)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            old_pc <= 32'b0;
            pc <= 32'b0;
            program_on <= 1'b0;
            flush <= 1'b0;
        end else begin
            program_on <= 1'b1;
            if (program_on) begin
                if (mret) begin
                    pc <= csr_pc;
                    flush <= 1'b1;
                end else if (exception) begin
                    pc <= handler_pc;
                    flush <= 1'b1;
                end else if (BranchTaken) begin
                    pc <= BranchTarget;
                    flush <= 1'b1;
                end else if (!stall_dcache) begin
                    pc <= pc + 4;
                    old_pc <= pc;
                    flush <= 1'b0;
                end
            end
        end
    end

    assign pc_real = stall_dcache ? old_pc : pc;
endmodule
