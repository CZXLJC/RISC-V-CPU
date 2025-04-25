`timescale 1ns / 1ps

module uart_tx_handler(
    input logic        clk,
    input logic        clk_x,
    input logic        rst_n,
    input logic [31:0] inst,
    input logic        inst_valid,
    output logic       uart_tx,
    output logic       uart_tx_done,
    output logic       data_error
);
    logic [7:0] data_in;
    logic [31:0] inst_buffer;
    logic start_flag;
    logic inst_valid_out0,inst_valid_out1;
    logic inst_valid_ready;
    logic [2:0] i;
    typedef enum logic [1:0] { 
    IDLE = 2'b00,
    PROCESSING = 2'b01,
    SENDING = 2'b10,
    DONE = 2'b11
     } tx_init_state;

     tx_init_state current_state, next_state;

    // 发送数据
    always_ff @(posedge clk_x or negedge rst_n) begin
        if (!rst_n) begin
            data_in <= 8'b0;
            start_flag <= 0;
            inst_valid_out0 <= 0;
            inst_valid_out1 <= 0;
            inst_valid_ready <= 0;
            current_state <= IDLE;
            next_state <= IDLE;
            i <= 3'b0;
        end else begin
            inst_valid_out0 <= inst_valid;
            inst_valid_out1 <= inst_valid_out0;
            inst_valid_ready <= inst_valid_out0 & ~inst_valid_out1;
            case (current_state)
            IDLE: begin
                if (inst_valid_ready) begin
                    next_state <= PROCESSING;
                    inst_buffer <= inst;
                end else begin
                    next_state <= IDLE;
                end
            end
            PROCESSING: begin
                if (i < 4) begin
                    start_flag <= 1;
                    data_in <= inst_buffer[31:24];
                    inst_buffer <= {inst_buffer[23:0],8'b0};
                    i <= i + 1;
                    next_state <= SENDING;
                end else begin
                    i <= 3'b0;
                    next_state <= DONE;
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
                start_flag <= 0;
                inst_buffer <= 32'b0;
            end
            endcase
            current_state <= next_state;
        end
    end

    // UART发送模块实例化
    uart_tx u_uart_tx (
        .clk_x(clk_x),
        .rst_n(rst_n),
        .data_in(data_in),
        .start_flag(start_flag),
        .uart_tx(uart_tx),
        .uart_tx_done(uart_tx_done)
    );

    // 错误检测逻辑
    assign data_error = (inst_valid && inst[31:8] != 24'h0) ? 1'b1 : 1'b0;


endmodule