`timescale 1ns / 1ps

`include "Const.svh"
module BRU(
    input logic [`BRUCONTROL_WIDTH] BRUControl,
    input logic [`DATA_WID] ALUResult,
    input logic Branch,
    input logic Jump,
    input logic [`DATA_WID] pc_curr_ex,
    input logic [`DATA_WID] imm32,
    output logic BranchTaken,
    output logic [`DATA_WID] BranchTarget
);

    always_comb begin
        if (Jump) begin
            BranchTaken = 1'b1; // Jump always taken
            BranchTarget = pc_curr_ex + imm32; // Calculate the target address for Jump
        end else begin
           case (BRUControl)
            3'b000: begin // BEQ
                BranchTaken = (ALUResult == 0) && Branch;
                BranchTarget = pc_curr_ex + imm32;
            end
            3'b001: begin // BNE
                BranchTaken = (ALUResult != 0) && Branch;
                BranchTarget = pc_curr_ex + imm32;
            end
            3'b100: begin // BLT
                BranchTaken = (ALUResult < 0) && Branch;
                BranchTarget = pc_curr_ex + imm32;
            end
            3'b101: begin // BGE
                BranchTaken = (ALUResult >= 0) && Branch;
                BranchTarget = pc_curr_ex + imm32;
            end
            3'b110: begin // BLTU
                BranchTaken = (ALUResult == 1) && Branch; 
                BranchTarget = pc_curr_ex + imm32;
            end
            3'b111: begin // BGEU
                BranchTaken = (ALUResult == 0) && Branch; 
                BranchTarget = pc_curr_ex + imm32;
            end
            default: begin // Default case
                BranchTaken = 1'b0; // No branch taken
                BranchTarget = pc_curr_ex + 4; // Next instruction address
            end
            endcase
        end
    end
endmodule