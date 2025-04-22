`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/16 09:09:11
// Design Name: 
// Module Name: ImmGen
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


module ImmGen(
    input logic [31:0] instruction,
    output logic [31:0] imm32
    );
    logic [6:0] opcode;
    logic [11:0] imm12;
    logic [19:0] imm20;
    logic [31:0] immI, immS, immB, immU, immJ;
    logic [31:0] immR;

    assign opcode = instruction[6:0];
    assign imm12 = instruction[31:20];
    assign imm20 = instruction[31:12];
    assign immI = {{20{imm12[11]}}, imm12};
    assign immS = {{20{imm12[11]}}, imm12};
    assign immB = {{19{imm12[11]}}, imm12, 1'b0};
    assign immU = {imm20, 12'b0};
    assign immJ = {{11{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
    assign immR = 32'b0;
    // Generate immediate value based on opcode
    always_comb begin
        case (opcode)
            7'b0000011: imm32 = immI; // Load
            7'b0010011: imm32 = immI; // Immediate
            7'b0100011: imm32 = immS; // Store
            7'b1100011: imm32 = immB; // Branch
            7'b0110111: imm32 = immU; // LUI
            7'b0010111: imm32 = immU; // AUIPC
            7'b1101111: imm32 = immJ; // JAL
            default:    imm32 = immR; // R-type or other
        endcase
    end
endmodule
