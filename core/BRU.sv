`timescale 1ns / 1ps

module BRU(
    input logic [1:0] BLUControl,
    input logic [31:0] ALUResult,
    input logic Branch,
    input logic Jump,
    input logic [31:0] pc,
    input logic [31:0] Imm32,
    output logic BranchTaken,
    output logic [31:0] BranchTarget
);

    always_comb begin
        if (Jump) begin
            BranchTaken = 1'b1; // Jump always taken
            BranchTarget = pc + Imm32; // Calculate the target address for Jump
        end else begin
           case (BLUControl)
            2'b00: begin // BEQ
                BranchTaken = (ALUResult == 0) && Branch;
                BranchTarget = pc + Imm32; // Calculate the target address for BEQ
            end
            2'b01: begin // BNE
                BranchTaken = (ALUResult != 0) && Branch;
                BranchTarget = pc + Imm32; // Calculate the target address for BNE
            end
            // todo: Add more branch conditions as needed
            endcase
        end
    end
endmodule