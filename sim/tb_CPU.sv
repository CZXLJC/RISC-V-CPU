
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/17 08:39:49
// Design Name: 
// Module Name: tb_CPU
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


//~ `New testbench
`timescale  1ns / 1ps

module tb_CPU;

// CPU Parameters
parameter PERIOD  = 10;


// CPU Inputs
logic clk                            = 0 ;
logic rst_n                          = 0 ;
logic [31:0] instruction             = 0 ;
logic [13:0] pc                            = 0 ;

// CPU Outputs



initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD) rst_n  =  1;
end

CPU  u_CPU (
    .clk                 (clk                  ),
    .rst_n               (rst_n                ),
    .instruction  (instruction   )
    // .pc                 (pc                  )
);

initial
begin
    // Initialize Inputs
    #(PERIOD*1.5);
    // Test case 1: Basic instruction
    // addi x1, x0, 5
    instruction = 32'b00000000010100000000000010010011; // opcode for addi
    #PERIOD;
    // Check outputs
    // assert (rdata1 == 5) else $error("Test case 1 failed: rdata1 should be 5");
    // assert (RegWrite == 1) else $error("Test case 1 failed: RegWrite should be 1");
    // assert (MemWrite == 0) else $error("Test case 1 failed: MemWrite should be 0");
    // assert (imm32 == 5) else $error("Test case 1 failed: imm32 should be 5");
    // Test case 2
    // addi x2, x1, 10
    instruction = 32'b00000000101000001000000100010011;; // opcode for addi
    #PERIOD;
    // Test case 3
    // add x3, x1, x2
    instruction = 32'b00000000001000001000000110110011;
    #PERIOD;

    // Test case 4
    // sub x4, x1, x2
    instruction = 32'b01000000001000001000001000110011; // opcode for sub
    #PERIOD;

    // Test case 5
    // jal x6, -4
    instruction = 32'hffdff36f; // opcode for jal

//     // Test case 5： B type instruction  

    // pc = pc + 1;
    // #PERIOD;
    // pc = pc + 1;
    // #PERIOD;
    // pc = pc + 1;
    // #PERIOD;
    // pc = pc + 1;
    // #PERIOD;

    // #PERIOD;
    $finish;
end

endmodule
