`timescale 1ns / 1ps

`include "Const.svh"
module PC(
    input  logic clk,
    input  logic rst_n,
    input  logic [31:0] new_pc,  // 新的PC值
    output logic [31:0] pc_curr      // 当前PC值
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_curr <= 32'h0000_0000;  // 初始化PC为0
        end else begin
            pc_curr <= new_pc;
        end
    end
endmodule