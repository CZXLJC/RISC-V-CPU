`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/16 08:46:59
// Design Name: 
// Module Name: Registers
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
module Registers(
    input logic clk,
    input logic rst_n,
    input logic RegWrite,
    input logic [`REG_ID_WID] rs1,
    input logic [`REG_ID_WID] rs2,
    input logic [`REG_ID_WID] rd,
    input logic [`DATA_WID] writeData,
    output logic [`DATA_WID] rdata1,
    output logic [`DATA_WID] rdata2
    );
    reg [`DATA_WID] registers [31:0];

    always_ff @(posedge clk or negedge rst_n) begin : reg_write
        if (!rst_n) begin
            registers[0] = 32'b0;
            for (integer i = 1; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end else if (RegWrite && (rd != 5'b0)) begin
            registers[rd] <= writeData;
        end
    end
    assign rdata1 = registers[rs1];
    assign rdata2 = registers[rs2];
endmodule
