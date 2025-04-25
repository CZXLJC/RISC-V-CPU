`timescale 1ns / 1ps

module top(
    input wire clk,
    input wire rst_n,
    input wire uart_rx,
    output wire uart_tx,
    output logic[7:0] seg,
    output logic[7:0] seg1,
    output logic[7:0] an
);

    logic clk_x, clk_16x, clk_ms, clk_500ms, clk_1s;

    logic [31:0] inst;
    logic inst_valid;
    logic data_error;
    divclk u_divclk(
        .clk(clk),
        .clk_16x(clk_16x),
        .clk_x(clk_x),
        .clk_ms(clk_ms),
        .clk_500ms(clk_500ms),
        .clk_1s(clk_1s)
    );

    uart_rx_handler u_uart_rx_handler(
        .clk(clk),
        .clk_16x(clk_16x),
        .rst_n(rst_n),
        .uart_rx(uart_rx),
        .inst(inst),
        .inst_valid(inst_valid),
        .data_error(data_error)
    );

    ShowLED u_ShowLED(
        .clk(clk),
        .clk_ms(clk_ms),
        .rst_n(rst_n),
        .inst(inst),
        .inst_valid(inst_valid),
        .seg(seg),
        .seg1(seg1),
        .an(an)
    );
    

endmodule