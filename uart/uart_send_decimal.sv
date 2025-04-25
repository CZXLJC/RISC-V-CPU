`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/15 14:24:22
// Design Name: 
// Module Name: uart_send_decimal
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


module uart_send_decimal (
    input logic clk_x,        // 时钟信号
    input logic clk_500ms,    // 500ms时钟信号
    input logic rst_n,        // 异步复位，低电平有效
    input logic [31:0] number,// 要发送的32位十进制数
    input logic start_flag,    // 按键输入
    output logic uart_tx    // UART发送引脚
);

    logic start_flag_out0,start_flag_out1;
    logic start_flag_ready;
    parameter IDLE = 3'b000;
    parameter PROCESSING = 3'b001;
    parameter SENDING = 3'b010;
    parameter DONE = 3'b100;
    logic [2:0] state, next_state;
    // logic [7:0] ascii_char;
    logic [7:0] BCD_char;
    logic [31:0] number_in_buffer;
    logic [7:0] tx_data;
    logic tx_start;
    logic [3:0] i;
    logic uart_tx_done;

    // 状态机逻辑
    always @(posedge clk_x or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            i <= 0;
            tx_start <= 0;
            start_flag_out0 <= 5'b0;
            start_flag_out1 <= 5'b0;
            start_flag_ready <= 5'b0;
            number_in_buffer <= 0;
            tx_data <= 0;
        end else begin
            tx_start <= 0;
            start_flag_out0<=start_flag;
            start_flag_out1<=start_flag_out0;
            start_flag_ready<=start_flag_out0&~start_flag_out1;
            case (state)
            IDLE: begin
                if (start_flag_ready || clk_500ms) begin
                    number_in_buffer <= number;
                    // BCD_char <= number[4:0] + 48;
                    i <= 9;
                    next_state <= PROCESSING;
                end else begin
                    next_state <= IDLE;
                end
            end
            PROCESSING: begin
                if (number_in_buffer == 0 && i == 0) begin
                    next_state <= DONE;
                end else begin
                    if (i > 0) begin
                        // ascii_char <= number_in_buffer % 10 + 48;
                        // number_in_buffer <= number_in_buffer / 10;
                        // tx_data <= ascii_char;
                        BCD_char <= number_in_buffer[31:28] + 48;
                        number_in_buffer <= number_in_buffer << 4;
                        tx_data <= BCD_char;
                        next_state <= SENDING;
                        tx_start <= 1;
                        i <= i - 1;
                    end else begin
                        next_state <= DONE;
                    end
                end
            end
            SENDING: begin
            if (uart_tx_done) begin
                next_state <= PROCESSING;
            end else begin
                next_state <= SENDING;
            end
            end
            DONE: begin
                next_state <= IDLE;
                tx_data <= 0;
                BCD_char <= 0;
                i <= 0;
            end
            endcase
            state <= next_state;
        end
    end

    uart_tx uart_tx_init(
        .clk_x(clk_x),
        .data_in(tx_data),
        .start_flag(tx_start), 
        .txd(uart_tx),
        .rst_n(rst_n),
        .uart_tx_done(uart_tx_done)
    );
endmodule