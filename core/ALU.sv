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


module ALU(
    input logic [31:0] A,
    input logic [31:0] B,
    input logic [3:0] ALUControl, // 该信号是{funct7[30], funct3}的拼接
    output logic [31:0] ALUResult,
    output logic Overflow, // 暂时用不上这两个信号
    output logic CarryOut
);
    logic [32:0] AddResult, SubResult;

    always_comb begin
        // Precompute addition and subtraction with extended sign bit
        AddResult = {A[31], A} + {B[31], B};
        SubResult = {A[31], A} - {B[31], B};
        
        case (ALUControl)
            // ADD (signed)
            4'b0000: begin
                ALUResult = AddResult[31:0];
                Overflow = (A[31] == B[31]) && (ALUResult[31] != A[31]);
                CarryOut = AddResult[32];
            end
            
            // SUB (signed)
            4'b1000: begin
                ALUResult = SubResult[31:0];
                Overflow = (A[31] != B[31]) && (ALUResult[31] != A[31]);
                CarryOut = SubResult[32];  // 1 indicates borrow (A < B)
            end
            
            // SLL (Shift Left Logical)
            4'b0001: begin
                ALUResult = A << B[4:0];
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            
            // SLT (Set Less Than - signed)
            4'b0010: begin
                ALUResult = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            
            // SLTU (Set Less Than - unsigned)
            4'b0011: begin
                ALUResult = (A < B) ? 32'b1 : 32'b0;
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            
            // XOR
            4'b0100: begin
                ALUResult = A ^ B;
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            
            // SRL (Shift Right Logical)
            4'b0101: begin
                ALUResult = A >> B[4:0];
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            
            // SRA (Shift Right Arithmetic)
            4'b1101: begin
                ALUResult = $signed(A) >>> B[4:0];
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            
            // OR
            4'b0110: begin
                ALUResult = A | B;
                Overflow = 1'b0;
                CarryOut = 1'b0;
            end
            
            // AND
            4'b0111: begin
                ALUResult = A & B;
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
