`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/22 06:49:06
// Design Name: 
// Module Name: DCache
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
module DCache#(
    parameter CACHE_WID = 4
)(
    input  logic             clk, rst_n
    // ,  
    // input  logic             MemRead, MemWrite,
    // input  logic [31:0]      addr,
    // input  logic [31:0]      wdata,
    // output logic [31:0]      rdata,
    // output logic             hit, miss,
    // output logic             stall, // 读写冲突
    // output logic             dirty, // 脏位
    // output logic             valid, // 有效位
    // output logic [31:0]      cache_addr, // 缓存地址
    // output logic [31:0]      cache_wdata, // 缓存写入数据
    // output logic [31:0]      cache_rdata, // 缓存读取数据
    // output logic             cache_hit, // 缓存命中
    // output logic             cache_miss, // 缓存未命中
    // output logic             cache_stall, // 缓存读写冲突
    // output logic             cache_dirty, // 缓存脏位
    // output logic             cache_valid // 缓存有效位
    );
    // Store Buffer
    typedef struct packed {
        logic [31:0] addr;
        logic [31:0] data;         
        logic        valid;        
    } Store_Buffer_t;

    // Cache行定义
    typedef struct packed {
        logic [31:0] data;         // 数据
        logic        valid;        // 有效位
        logic        dirty;        // 脏位
    } cache_line_t;
endmodule
