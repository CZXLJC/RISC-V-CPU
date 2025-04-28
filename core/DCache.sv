`timescale 1ns / 1ps
`include "Const.svh"

module DCache #(
    parameter CACHE_WID = 4         // Cache索引位宽（缓存条目数=2^CACHE_WID）
)(
    input  logic             clk, 
    input  logic             rst_n,
    input  logic [`DATA_WID] addr,                 // 访问地址
    input  logic [`DATA_WID] data_write,           // 写入数据
    input  logic [2:0]       MEMControl,           // 存储控制信号，funct3
    input  logic             MemRead,              // 读使能
    input  logic             MemWrite,             // 写使能
    output logic [`DATA_WID] data_read,            // 读取数据
    output logic             stall_dcache          // 暂停信号
);

// 缓存行结构
localparam CACHE_SIZE = 1 << CACHE_WID;         // 缓存条目数
localparam TAG_WIDTH = 32 - CACHE_WID - 2;      // Tag位宽 = 32 - index位宽 - offset位宽

typedef struct packed {
    logic [TAG_WIDTH-1:0] tag;    // Tag位，用于标识缓存行
    logic [31:0]          data;   // 数据
    logic                 valid;  // 有效位
    logic                 dirty;  // 脏位（写回策略使用），指示是否被修改但未写回内存
} cache_line_t;

cache_line_t cache [0:CACHE_SIZE-1]; // 缓存存储器

// 信号定义
logic [`DATA_WID] mem_data_read;       // 从内存读取的数据
logic [3:0]       mem_byte_enable;     // 内存字节使能
logic             mem_write_enable;    // 内存写使能
logic             write_pending;       // 写操作未命中标志

// 控制信号定义
logic set_write_pending;   // 设置write_pending信号
logic clear_write_pending; // 清除write_pending信号

logic read_mem_cnt;
logic write_mem_cnt;

// 请求地址寄存器
logic [`DATA_WID] req_addr;            // 保存请求地址
logic [CACHE_WID-1:0] req_index;       // 保存请求索引
logic [1:0]           req_offset;      // 保存请求偏移
logic [TAG_WIDTH-1:0] req_tag;         // 保存请求Tag
// logic [3:0]           req_sll;         // 保存请求SLL（用于字节选择）

// 地址分解
logic [TAG_WIDTH-1:0] curr_tag;
logic [CACHE_WID-1:0] curr_index;
logic [1:0]           curr_offset;

assign curr_tag    = addr[31 : CACHE_WID+2];
assign curr_index  = addr[CACHE_WID+1 : 2];
assign curr_offset = addr[1:0];

// 缓存命中判断
logic hit;
assign hit = cache[curr_index].valid && (cache[curr_index].tag == curr_tag);

// 状态机定义
typedef enum logic [1:0] {
    IDLE,         // 空闲状态
    READ_MEM,     // 从内存读取数据
    WRITE_MEM,    // 将数据写回内存
    WRITE_CACHE   // 将数据写入缓存
} state_t;

state_t state, next_state;

logic [31:0] updated_data;

// 时序逻辑：状态更新和缓存初始化
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        write_pending <= 0;
        for (int i = 0; i < CACHE_SIZE; i++) begin
            cache[i].tag <= 0;
            cache[i].data <= 0;
            cache[i].valid <= 0;
            cache[i].dirty <= 0;
        end
        req_addr <= 4;
        req_index <= 4;
        req_offset <= 4;
        req_tag <= 4;
        read_mem_cnt <= 0;
        write_mem_cnt <= 1; // 暂时默认写内存用1个周期
    end else begin
        state <= next_state;

        // 处理write_pending信号
        if (set_write_pending) begin
            write_pending <= 1;
        end else if (clear_write_pending) begin
            write_pending <= 0;
        end

        if (state == IDLE && (MemRead || MemWrite)) begin
            req_addr <= addr;
            req_index <= curr_index;
            req_offset <= curr_offset;
            req_tag <= curr_tag;
        end
        if (state == WRITE_CACHE) begin
            if (write_pending) begin
                // 写未命中：更新缓存数据并设置dirty
                cache[req_index].data <= updated_data;
                cache[req_index].tag <= req_tag;
                cache[req_index].valid <= 1;
                cache[req_index].dirty <= 1;
                write_pending <= 0;
            end else begin
                // 读未命中：将内存数据写入缓存
                cache[req_index].data <= mem_data_read;
                cache[req_index].tag <= req_tag;
                cache[req_index].valid <= 1;
                cache[req_index].dirty <= 0;
            end
        end else if (state == IDLE && MemWrite && hit) begin
            // 写命中：更新缓存数据并设置dirty
            cache[curr_index].data <= updated_data;
            cache[curr_index].dirty <= 1;
        end

        if (state == READ_MEM) begin
            read_mem_cnt <= 1;
        end else begin
            read_mem_cnt <= 0;
        end
    end
end

// 数据更新逻辑（用于写操作）
always_comb begin
    if (write_pending) begin
        // 写不命中，即写需要等待内存读取，因此更新的数据应该基于内存读取的数据！
        updated_data = mem_data_read;
    end else begin
        updated_data = cache[req_index].data;
    end
    case (MEMControl)
        3'b000: begin // sb
            updated_data[req_offset*8 +: 8] = data_write[7:0];
        end
        3'b001: begin // sh
            if (req_offset[0] == 0) begin // 偏移为偶数
                updated_data[req_offset*8 +: 16] = data_write[15:0];
            end
        end
        3'b010: begin // sw
            updated_data = data_write;
        end
        default: updated_data = cache[req_index].data;
    endcase
end

// 状态机和控制逻辑
always_comb begin
    next_state = state;
    stall_dcache = 0;
    mem_write_enable = 0;
    mem_byte_enable = 4'b0000;
    data_read = 32'b0;
    // 默认控制信号置零
    set_write_pending = 0;
    clear_write_pending = 0;
    case (state)
        IDLE: begin
            if (MemRead) begin
                if (hit) begin
                    // 命中时从缓存读取数据
                    case (MEMControl)
                        3'b000: begin // lb
                            data_read = {{24{cache[curr_index].data[curr_offset*8 + 7]}}, cache[curr_index].data[curr_offset*8 +: 8]};
                        end
                        3'b001: begin // lh
                            if (curr_offset[0] == 0) begin
                                data_read = {{16{cache[curr_index].data[curr_offset*8 + 15]}}, cache[curr_index].data[curr_offset*8 +: 16]};
                            end
                        end
                        3'b010: begin // lw
                            data_read = cache[curr_index].data;
                        end
                        default: data_read = cache[curr_index].data;
                    endcase
                end else begin
                    // 未命中，设置write_pending = 0
                    // write_pending = 0;
                    clear_write_pending = 1; // 原write_pending = 0
                    stall_dcache = 1;
                    if (cache[curr_index].valid && cache[curr_index].dirty) begin
                        next_state = WRITE_MEM;
                    end else begin
                        next_state = READ_MEM;
                    end
                end
            end else if (MemWrite) begin
                if (hit) begin
                    // 写命中：在时序逻辑中更新缓存
                end else begin
                    // 未命中，设置write_pending = 1
                    // write_pending = 1;
                    set_write_pending = 1; // 原write_pending = 1
                    stall_dcache = 1;
                    if (cache[curr_index].valid && cache[curr_index].dirty) begin
                        next_state = WRITE_MEM;
                    end else begin
                        next_state = READ_MEM;
                    end
                end
            end
        end

        READ_MEM: begin
            // 等待内存读取完成，耗时两个周期
            if (read_mem_cnt) begin
                next_state = WRITE_CACHE;
            end
            stall_dcache = 1;
        end

        WRITE_MEM: begin
            mem_write_enable = 1;
            mem_byte_enable = 4'b1111; // 写回整个字
            next_state = READ_MEM;
            stall_dcache = 1;
        end

        WRITE_CACHE: begin
            if (!write_pending) begin
                // 读未命中：返回内存数据
                // data_read = mem_data_read;
                case (MEMControl)
                        3'b000: begin // lb
                            data_read = {{24{mem_data_read[req_offset*8 + 7]}}, mem_data_read[req_offset*8 +: 8]};
                        end
                        3'b001: begin // lh
                            if (req_offset[0] == 0) begin
                                data_read = {{16{mem_data_read[req_offset*8 + 15]}}, mem_data_read[req_offset*8 +: 16]};
                            end
                        end
                        3'b010: begin // lw
                            data_read = mem_data_read;
                        end
                        default: data_read = cache[curr_index].data;
                endcase
            end else begin
                clear_write_pending = 1;
            end
            next_state = IDLE;
            stall_dcache = 0;
        end
    endcase
end

// 内存接口例化
DataMem u_DataMem (
    .clka(clk),
    .wea(mem_write_enable ? mem_byte_enable : 4'b0),
    .addra(req_addr >> 2),
    .dina(cache[req_index].data), // 写回时使用缓存数据
    .douta(mem_data_read)
);

endmodule