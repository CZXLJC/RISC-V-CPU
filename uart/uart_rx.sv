`timescale 1ns / 1ps

module uart_rx (
    input  logic        clk_16x,      // 16x baud rate sampling clock
    input  logic        rst_n,        // Active-low reset
    input  logic        rxd,          // Serial data input
    output logic        data_ready,   // Data ready strobe
    output logic        data_error,   // Parity error flag
    output logic [7:0] data_in     // Display data output
);

typedef enum logic [1:0] {
    IDLE,
    DATA,
    PARITY,
    STOP
} state_t; 

logic [7:0]  data_out;        // 接收数据寄存器
logic [7:0]  data_out1;       // 输出数据寄存器
logic        rxd_buf;         // RXD缓冲寄存器
logic [15:0] clk_16x_cnt;     // 16x时钟计数器
logic        rxd1, rxd2;      // 亚稳态消除寄存器
logic        start_flag;      // 起始位检测标志
state_t      current_state;   // 当前状态
state_t      next_state;      // 下一状态

assign data_in  = data_out1;  // 合并显示数据赋值
logic check_bit;                        // 奇偶校验位
assign check_bit  = ^data_out;          // 生成奇偶校验位

// ================== 初始化 ==================
// initial begin
//     clk_16x_cnt   = '0;
//     current_state  = IDLE;
//     next_state     = IDLE;
//     rxd1           = 1'b1;
//     rxd2           = 1'b1;
//     data_ready     = 1'b0;
//     start_flag     = 1'b0;
// end

always_ff @(posedge clk_16x or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

always_comb begin
    next_state = current_state;  
    case (current_state)
        IDLE: begin
            if (start_flag && (clk_16x_cnt > 8)) begin
                next_state = DATA;
            end
        end
        DATA: begin
            if (clk_16x_cnt > 136) begin
                next_state = PARITY;
            end
        end
        PARITY: begin
            if (clk_16x_cnt > 152) begin
                next_state = STOP;
            end
        end
        STOP: begin
            if (clk_16x_cnt > 168) begin
                next_state = IDLE;
            end
        end
    endcase
end

always_ff @(posedge clk_16x or negedge rst_n) begin
    if (!rst_n) begin
        // 异步复位初始化
        rxd1          <= 1'b1;
        rxd2          <= 1'b1;
        data_ready    <= 1'b0;
        data_error    <= 1'b0;
        clk_16x_cnt   <= '0;
        start_flag    <= 1'b0;
        data_out      <= '0;
        data_out1     <= '0;
        rxd_buf       <= 1'b1;
    end else begin
        // 亚稳态处理链
        rxd1 <= rxd;
        rxd2 <= rxd1;

        case (current_state)
            IDLE: begin
                data_ready <= 1'b0;
                if (!rxd1 && rxd2) begin  // 检测下降沿
                    start_flag  <= 1'b1;
                end
                if (start_flag) begin
                    clk_16x_cnt <= clk_16x_cnt + 16'd1;
                end
            end

            DATA: begin
                clk_16x_cnt <= clk_16x_cnt + 16'd1;
                case (clk_16x_cnt)
                    24:  data_out[0] <= rxd2;  // 在采样点捕获数据
                    40:  data_out[1] <= rxd2;
                    56:  data_out[2] <= rxd2;
                    72:  data_out[3] <= rxd2;
                    88:  data_out[4] <= rxd2;
                    104: data_out[5] <= rxd2;
                    120: data_out[6] <= rxd2;
                    136: data_out[7] <= rxd2;
                endcase
            end

            PARITY: begin
                clk_16x_cnt <= clk_16x_cnt + 16'd1;
                if (clk_16x_cnt == 152) begin
                    data_error <= (rxd2 != check_bit);  // 校验错误判断
                end
            end

            STOP: begin
                clk_16x_cnt <= clk_16x_cnt + 16'd1;
                if (clk_16x_cnt == 168) begin
                    data_ready  <= 1'b1;
                    data_out1   <= data_out;  // 锁存输出数据
                    data_error  <= !rxd2;     // 停止位错误检测
                end else if (clk_16x_cnt > 168) begin
                    data_ready  <= 1'b0;
                    clk_16x_cnt <= '0;
                    start_flag  <= 1'b0;
                end
            end
        endcase
    end
end

endmodule