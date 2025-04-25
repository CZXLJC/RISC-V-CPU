`timescale 1ns / 1ps

module uart_rx_handler(
    input  logic        clk,         // 主时钟
    input  logic        clk_16x,     // 16x波特率时钟
    input  logic        rst_n,       // 复位信号
    input  logic        uart_rx,     // UART接收线
    output logic [31:0] inst,
    output logic        inst_valid,   // 有效指令标志
    output logic        data_error
);
    logic [7:0]  data_in;
    logic        data_ready;
    logic        uart_error;

    logic [2:0]  data_cnt;
    logic [31:0] rx_buffer;
    logic full;
    
    uart_rx u_uart_rx (
        .clk_16x(clk_16x),
        .rst_n(rst_n),
        .rxd(uart_rx),
        .data_in(data_in),
        .data_ready(data_ready),
        .data_error(uart_error)
    );

    // Queue u_queue (
    //     .clk_16x(clk_16x),
    //     .rst_n(rst_n),
    //     .data_in(data_in),
    //     .data_ready(data_ready && !uart_error),
    //     .inst_valid(inst_valid),
    //     .inst(inst)
    // );

    

    always_ff @(posedge clk_16x or negedge rst_n) begin
        if (!rst_n || full) begin
            data_cnt <= 0;
            rx_buffer <= 0;
        end else begin
            if (data_ready && !uart_error) begin
                data_cnt <= data_cnt + 1;
                rx_buffer <= {rx_buffer[23:0], data_in}; // 自动移位优化
            end else if (uart_error) begin
                {data_cnt, rx_buffer} <= 0;
            end else begin
                data_cnt <= data_cnt;
                rx_buffer <= rx_buffer;
            end
        end
    end

    assign full = (data_cnt == 4); // 4个字节有效
    assign data_error = uart_error;
    assign inst = rx_buffer;
    assign inst_valid = (data_cnt == 4) && !uart_error; // 3个字节有效
endmodule
