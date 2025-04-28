`timescale 1ns/1ps
//
// Module Name: divclk
// Revision 0.02 - File Optimized
// Additional Comments:
// 分频模块优化版：使用参数、always_ff和统一非阻塞赋值
//

module divclk(
    input  logic clk,         // 100MHz 系统时钟
    output logic clk_16x = 0,     // 16倍的波特率采样时钟 153600Hz (9.6KHz*16)
    output logic clk_x = 0,       // 9600Hz 波特率时钟
    output logic clk_ms = 0, // 1KHz 时钟信号
    output logic clk_500ms = 0,    // 500ms 时钟信号
    output logic clk_1s = 0        // 1s 时钟信号
);

    // 参数定义
    parameter int CNT_MS      = 50000;   // 100M/1000 = 100kHz (生成1KHz信号)
    parameter int CNT_16X      = 326;     // 100M/153600, 产生 clk_16x
    // parameter int CNT_16X_TO_X = 8; // 16倍分频
    parameter int CNT_X     = 5208;
    parameter int CNT_MS_TO_500MS = 250; // 1KHz * 500ms = 500
    parameter int CNT_1S     = 500;    // 1KHz * 1s = 1000


    // 内部信号定义
    logic [15:0] cnt_ms = 0;
    logic [11:0] cnt_16x = 0; 
    logic [15:0] cnt_x = 0;
    logic [11:0] cnt_500ms = 0; 
    logic [11:0] cnt_1s = 0; 

    // 系统时钟分频：
    // 分频产生 clk_ms (1KHz)
    always_ff @(posedge clk) begin
        if(cnt_ms == CNT_MS) begin
            clk_ms <= ~clk_ms;
            cnt_ms   <= 0;
        end else begin
            cnt_ms <= cnt_ms + 1;
        end
    end

    // 分频产生 clk_16x (153600Hz)
    always_ff @(posedge clk) begin
        if(cnt_16x == CNT_16X) begin
            clk_16x <= ~clk_16x;
            cnt_16x    <= 0;
        end else begin
            cnt_16x <= cnt_16x + 1;
        end
    end

    // 通过 clk_16x 产生 9600Hz 时钟信号
    // always_ff @(posedge clk_16x) begin
    //     if(cnt_x == CNT_16X_TO_X) begin
    //         clk_x <= ~clk_x;
    //         cnt_x  <= 0;
    //     end else begin
    //         cnt_x <= cnt_x + 1;
    //     end
    // end

    // 通过 clk 产生 9600Hz 时钟信号
    always_ff @(posedge clk) begin
        if(cnt_x == CNT_X) begin
            clk_x <= ~clk_x;
            cnt_x  <= 0;
        end else begin
            cnt_x <= cnt_x + 1;
        end
    end

    // 通过 clk_ms 产生 500ms 时钟信号
    always_ff @(posedge clk_ms) begin
        if(cnt_500ms == CNT_MS_TO_500MS) begin
            clk_500ms <= ~clk_500ms;
            cnt_500ms <= 0;
        end else begin
            cnt_500ms <= cnt_500ms + 1;
        end
    end

    // 通过 clk_ms 产生 1s 时钟信号
    always_ff @(posedge clk_ms) begin
        if(cnt_1s == CNT_1S) begin
            clk_1s <= ~clk_1s;
            cnt_1s <= 0;
        end else begin
            cnt_1s <= cnt_1s + 1;
        end
    end

endmodule