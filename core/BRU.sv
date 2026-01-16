`timescale 1ns / 1ps

module BRU(
    input logic [2:0] BRUControl, // 等于 funct3
    input logic [31:0] ALUResult,
    input logic Branch,
    input logic Jump,
    input logic isJalr,
    input logic [31:0] pc,
    input logic [31:0] imm32,
    output logic BranchTaken,
    output logic [31:0] BranchTarget
);

    always_comb begin
        if (isJalr) begin
            BranchTarget = ALUResult; // JALR target address
        end else if (Jump || Branch) begin
            BranchTarget = pc + imm32; 
        end else begin
            BranchTarget = pc + 4; // Default next instruction address
        end
        
        if (Jump) begin
            BranchTaken = 1'b1; // Jump always taken
        end else begin
           case (BRUControl)
            3'b000: begin // BEQ
                BranchTaken = (ALUResult == 0) && Branch;
            end
            3'b001: begin // BNE
                BranchTaken = (ALUResult != 0) && Branch;
            end
            3'b100: begin // BLT
                BranchTaken = (ALUResult < 0) && Branch;
            end
            3'b101: begin // BGE
                BranchTaken = (ALUResult >= 0) && Branch;
            end
            3'b110: begin // BLTU
                BranchTaken = (ALUResult == 1) && Branch; 
            end
            3'b111: begin // BGEU
                BranchTaken = (ALUResult == 0) && Branch; 
            end
            default: begin // Default case
                BranchTaken = 1'b0; // No branch taken
                BranchTarget = pc + 4; // Next instruction address
            end
            endcase
        end
    end
endmodule