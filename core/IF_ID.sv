`timescale 1ns / 1ps


// This module implements the IF/ID pipeline register for a CPU design. It captures the current program counter (PC) and instruction fetched from memory, and holds them until they are needed in the next stage of the pipeline.
module IF_ID(
    input logic clk, rst_n,
    input logic [13:0] pc_curr,
    input logic [31:0] instruction_in,
    output logic [13:0] pc_next,
    output logic [31:0] instruction_out
);
    // Register to hold the current instruction and PC
    logic [13:0] pc_reg;
    logic [31:0] instruction_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_reg <= 14'b0;
            instruction_reg <= 32'b0;
        end else begin
            pc_reg <= pc_curr;
            instruction_reg <= instruction_in;
        end
    end

    // Output the current instruction and PC
    assign pc_next = pc_reg;
    assign instruction_out = instruction_reg;
endmodule