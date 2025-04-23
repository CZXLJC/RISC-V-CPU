`timescale 1ns / 1ps

module ICache(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] addr,        // 请求地址
    output logic [31:0] data,        // 缓存数据
    output logic        hit,         // 命中标志
    // 内存接口
    output logic [31:0] mem_addr,
    input  logic [31:0] mem_data,
    output logic        mem_read,
    input  logic        mem_ready
);
    // 缓存参数：4KB，直接映射，32字节块
    parameter CACHE_SIZE = 1024;  // 4KB/4B = 1024条目
    typedef struct packed {
        logic [27:0] tag;    // 32 - 5 (index) = 27
        logic [31:0] data;
        logic        valid;
    } cache_entry_t;

    cache_entry_t cache [0:CACHE_SIZE-1];
    logic [4:0]   index;
    logic [27:0]  tag;

    assign index = addr[6:2];  // 32字节块，5位索引
    assign tag = addr[31:5];

    // 缓存访问逻辑
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            foreach (cache[i]) cache[i].valid <= 1'b0;
        end else begin
            if (mem_ready) begin  // 填充缓存
                cache[index].tag <= tag;
                cache[index].data <= mem_data;
                cache[index].valid <= 1'b1;
            end
        end
    end

    // 命中判断
    assign hit = (cache[index].tag == tag) && cache[index].valid;
    assign data = cache[index].data;

    // 内存请求
    assign mem_read = !hit;
    assign mem_addr = {addr[31:5], 5'b0}; // 对齐到32字节
endmodule