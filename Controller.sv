`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/16 08:32:17
// Design Name: 
// Module Name: Controller
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


// `timescale 1ns / 1ps
// //////////////////////////////////////////////////////////////////////////////////
// // Company: 
// // Engineer: 
// // 
// // Create Date: 2025/04/09 06:14:58
// // Design Name: 
// // Module Name: l8p1
// // Project Name: 
// // Target Devices: 
// // Tool Versions: 
// // Description: 
// // 
// // Dependencies: 
// // 
// // Revision:
// // Revision 0.01 - File Created
// // Additional Comments:
// // 
// //////////////////////////////////////////////////////////////////////////////////


module Controller(
    input  logic [6:0] opcode,
    input  logic        Stall,      
    output logic RegWrite, MemWrite, MemRead, MemtoReg, ALUSrc, Branch,
    output logic [1:0] ALUOp,
    output logic Jump,
    output logic isJalr,
    output logic isAuipc
    );
    // Decode the instruction
    logic isR, isI, isS, isB, isU, isJ;
    logic isLoad, isImmediate;
    logic isLui;
    assign isR = (opcode == 7'b0110011);
    assign isI = (opcode == 7'b0010011 || opcode == 7'b0000011 || opcode == 7'b1100111);
    assign isLoad = (opcode == 7'b0000011);
    assign isImmediate = (opcode == 7'b0010011);
    // assign isJalr = (opcode == 7'b1100111);
    assign isS = (opcode == 7'b0100011);
    assign isB = (opcode == 7'b1100011);
    assign isU = (opcode == 7'b0110111 || opcode == 7'b0010111);
    // assign isLui = (opcode == 7'b0110111);
    // assign isAuipc = (opcode == 7'b0010111);
    assign isJ = (opcode == 7'b1101111); // i.e. JAL
    // Control signals
    // assign RegWrite = isR || isI || isU || isJ;
    // assign MemWrite = isS;
    // assign MemRead = isLoad;
    // assign MemtoReg = isLoad;
    // assign ALUSrc = isI || isS || isU || isJ;
    // assign Branch = isB;
    // assign ALUOp = 
    //     (isI || isS) ? 2'b00 : // I-type and S-type, perform add operation
    //     (isB) ? 2'b01 : // B-type, perform minus operation
    //     (isR) ? 2'b10 : // R-type
    //     2'b11; // default
    // assign Jump = isJ || isJalr; // JAL and JALR instructions
    assign isJalr = Stall ? 1'b0 : (opcode == 7'b1100111);
    assign isAuipc = Stall ? 1'b0 : (opcode == 7'b0010111);

    assign RegWrite = Stall ? 1'b0 : (isR || isI || isU || isJ);
    assign MemWrite = Stall ? 1'b0 : isS;
    assign MemRead = Stall ? 1'b0 : isLoad;
    assign MemtoReg = Stall ? 1'b0 : isLoad;
    assign ALUSrc = Stall ? 1'b0 : (isI || isS || isU || isJ);
    assign Branch = Stall ? 1'b0 : isB;
    assign ALUOp = 
        (isI || isS) ? 2'b00 : // I-type and S-type, perform add operation
        (isB) ? 2'b01 : // B-type, perform minus operation
        (isR) ? 2'b10 : // R-type
        2'b11; // default
    assign Jump = Stall ? 1'b0 : (isJ || isJalr); // JAL and JALR instructions
endmodule

