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

`include "Const.svh"
module ImmGen(
    input logic [`DATA_WID] instruction,
    output logic [`DATA_WID] imm32
    );
    logic [6:0] opcode;
    logic [11:0] imm12;
    logic [19:0] imm20;
    logic [4:0] rs1, rs2, rd;
    logic [`DATA_WID] immI, immS, immB, immU, immJ, immR;

    assign opcode = instruction[6:0];
    assign imm12 = instruction[31:20];
    assign imm20 = instruction[31:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = instruction[11:7];

    assign immI = {{20{imm12[11]}}, imm12};
    assign immS = {{20{imm12[11]}}, imm12[11:5], rd};
    assign immB = {{20{imm12[11]}}, rd[0], imm12[10:5], rd[4:1], 1'b0};
    assign immU = {imm20, 12'b0};
    assign immJ = {{12{imm20[19]}}, imm20[7:0], imm20[8], imm20[18:9], 1'b0};
    assign immR = 32'b0;
    // Generate immediate value based on opcode
    always_comb begin
        case (opcode)
            7'b0000011: imm32 = immI; // Load
            7'b0010011: imm32 = immI; // Immediate ALU
            7'b0100011: imm32 = immS; // Store
            7'b1100011: imm32 = immB; // Branch
            7'b0110111: imm32 = immU; // LUI
            7'b0010111: imm32 = immU; // AUIPC
            7'b1101111: imm32 = immJ; // JAL
            default:    imm32 = immR; // Default case
        endcase
    end
endmodule
