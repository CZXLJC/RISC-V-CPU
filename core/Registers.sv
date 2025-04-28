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


module Registers(
    input logic clk,
    input logic rst_n,
    input logic RegWrite,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [31:0] writeData,
    output logic [31:0] rdata1,
    output logic [31:0] rdata2,
    output logic [31:0] rdata3
    );
    reg [31:0] registers [31:0];

    always_ff @(posedge clk or negedge rst_n) begin : reg_write
        if (!rst_n) begin // 初始化
            registers[0] = 32'b0;
            for (integer i = 1; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end else if (RegWrite && (rd != 5'b0)) begin // 如果写入寄存器且不是x0
            registers[rd] <= writeData;
        end
    end
    assign rdata1 = registers[rs1];
    assign rdata2 = registers[rs2];
    assign rdata3 = registers[8]; // x8寄存器的值
endmodule
