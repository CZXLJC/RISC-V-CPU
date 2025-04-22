`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/16 09:03:54
// Design Name: 
// Module Name: ALUController
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


module ALUController(
    input logic [1:0] ALUOp,
    input logic funct7,
    input logic [2:0] funct3,
    output logic [3:0] ALUControl
    );
    always_comb begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0000; // ADD
            2'b01: ALUControl = 4'b1000; // SUB
            2'b10: ALUControl = {funct7, funct3};
            default: ALUControl = 4'b0000; // Default case
        endcase
    end
endmodule
