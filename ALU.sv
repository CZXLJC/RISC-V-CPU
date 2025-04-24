`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/16 08:58:38
// Design Name: 
// Module Name: ALU
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

`include "Const.svh"
module ALU(
    input logic [`DATA_WID] A,
    input logic [`DATA_WID] B,
    input logic [`ALUCONTROL_WIDTH] ALUControl,
    output logic [`DATA_WID] ALUResult,
    output logic Overflow,
    output logic CarryOut,
    output logic IllegalOp // Illegal operation flag
);
    logic [32:0] AddResult, SubResult;
    logic [63:0] product; // For multiplication

    always_comb begin
        // Precompute addition and subtraction with extended sign bit
        AddResult = {A[31], A} + {B[31], B};
        SubResult = {A[31], A} - {B[31], B};
        
        case (ALUControl)
            // ADD (signed)
            5'b00000: begin
                ALUResult = AddResult[31:0];
                Overflow = (A[31] == B[31]) && (ALUResult[31] != A[31]);
                CarryOut = AddResult[32];
            end
            // SUB (signed)
            5'b01000: begin
                ALUResult = SubResult[31:0];
                Overflow = (A[31] != B[31]) && (ALUResult[31] != A[31]);
                CarryOut = SubResult[32];  // 1 indicates borrow (A < B)
            end
            // SLL (Shift Left Logical)
            5'b00001: begin
                ALUResult = A << B[4:0];
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // SLT (Set Less Than - signed)
            5'b00010: begin
                ALUResult = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // SLTU (Set Less Than - unsigned)
            5'b00011: begin
                ALUResult = (A < B) ? 32'b1 : 32'b0;
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // XOR
            5'b00100: begin
                ALUResult = A ^ B;
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // SRL (Shift Right Logical)
            5'b00101: begin
                ALUResult = A >> B[4:0];
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // SRA (Shift Right Arithmetic)
            5'b01101: begin
                ALUResult = $signed(A) >>> B[4:0];
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // OR
            5'b00110: begin
                ALUResult = A | B;
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // AND
            5'b00111: begin
                ALUResult = A & B;
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // M拓展
            // MUL (signed), get the lower 32 bits
            5'b10000: begin
                product = $signed(A) * $signed(B);
                ALUResult = product[31:0];
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // MULH (signed), get the upper 32 bits
            5'b10001: begin
                product = $signed(A) * $signed(B);
                ALUResult = product[63:32];
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // MULHSU (signed * unsigned), get the upper 32 bits
            5'b10010: begin
                product = $signed(A) * B;
                ALUResult = product[63:32];
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // MULHU (unsigned), get the upper 32 bits
            5'b10011: begin
                product = A * B;
                ALUResult = product[63:32];
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // DIV (signed)
            5'b10100: begin
                if ($signed(B) == 0) begin
                    ALUResult = 32'b0;
                    IllegalOp = 1'b1;
                end else begin
                    ALUResult = $signed(A) / $signed(B);
                    IllegalOp = 1'b0;
                end
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // DIVU (unsigned)
            5'b10101: begin
                if (B == 0) begin
                    ALUResult = 32'b0;
                    IllegalOp = 1'b1;
                end else begin
                    ALUResult = A / B;
                    IllegalOp = 1'b0;
                end
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // REM (signed)
            5'b10110: begin
                if ($signed(B) == 0) begin
                    ALUResult = 32'b0;
                    IllegalOp = 1'b1;
                end else begin
                    ALUResult = $signed(A) % $signed(B);
                    IllegalOp = 1'b0;
                end
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // REMU (unsigned)
            5'b10111: begin
                if (B == 0) begin
                    ALUResult = 32'b0;
                    IllegalOp = 1'b1;
                end else begin
                    ALUResult = A % B;
                    IllegalOp = 1'b0;
                end
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            // Default case
            default: begin
                ALUResult = 32'b0;
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
        endcase
    end

endmodule
