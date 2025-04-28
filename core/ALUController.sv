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
            // 2'b01: ALUControl = 4'b1000; // SUB
            2'b01: begin
                if (funct3 == 3'b110 || funct3 == 3'b111) begin
                    ALUControl = 4'b0011; // SLTU, 即无符号比较，如果A < B，ALUResult = 1, 否则ALUResult = 0, 方便到时候直接通过ALUResult判断是否跳转
                end else begin
                    ALUControl = 4'b1000; // SUB
                end
            end
            2'b10: ALUControl = {funct7, funct3};
            2'b11: ALUControl = {2'b0, funct3}; 
        endcase
    end
endmodule
