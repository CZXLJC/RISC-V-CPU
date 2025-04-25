`timescale 1ns / 1ps
//
// Module Name: uart_tx
// Revision 0.02 - File Optimized
// Additional Comments:
// Optimized using SystemVerilog features
//

module uart_tx ( // 发送模块
    input  logic        clk_x,
    input  logic        rst_n,
    input  logic [7:0]  data_in, // 发送数据
    input  logic start_flag, // 发送使能信号
    output logic        uart_tx,
    output logic        uart_tx_done
);
    // 内部信号定义
   //  logic [7:0] led;
    logic [7:0] data_in_buf;
    logic start_flag0, start_flag1;
    logic start_flag_ready;
    
    // 使用typedef和enum定义状态机类型
    typedef enum logic [4:0] {
        IDLE  = 5'b00000,
        START = 5'b00001,
        B0    = 5'b00011,          
        B1    = 5'b00010,
        B2    = 5'b00110,
        B3    = 5'b00111,
        B4    = 5'b00101,
        B5    = 5'b00100,
        B6    = 5'b01100,
        B7    = 5'b01101,
        CHECK = 5'b01111,
        STOP  = 5'b01110
    } uart_state_t;

    uart_state_t current_state;

    // 使用always_ff替代always来描述时序逻辑
    always_ff @(posedge clk_x or negedge rst_n) begin
        if (~rst_n) begin
            current_state <= IDLE;
            uart_tx           <= 1'b1;
            uart_tx_done  <= 1'b0;
            data_in_buf   <= 8'b0;
            start_flag0   <= 1'b0;
            start_flag1   <= 1'b0;
            start_flag_ready <= 1'b0;
        end
        else begin
            // 发送使能信号的上升沿检测
            start_flag0 <= start_flag;
            start_flag1 <= start_flag0;
            start_flag_ready <= start_flag0 & ~start_flag1;
            
            case (current_state)
                IDLE: begin
                    uart_tx <= 1'b1;
                    uart_tx_done <= 1'b0;

               
                    if (start_flag_ready) begin
                        current_state <= START;
                        data_in_buf <= data_in;
                    end
                end
                
                START: begin
                    uart_tx <= 1'b0;  // 发送起始位
                    current_state <= B0;
                end
                
                B0: begin
                    uart_tx <= data_in_buf[0];
                    current_state <= B1;
                end
                
                B1: begin
                    uart_tx <= data_in_buf[1];
                    current_state <= B2;
                end
                
                B2: begin
                    uart_tx <= data_in_buf[2];
                    current_state <= B3;
                end
                
                B3: begin
                    uart_tx <= data_in_buf[3];
                    current_state <= B4;
                end
                
                B4: begin
                    uart_tx <= data_in_buf[4];
                    current_state <= B5;
                end
                
                B5: begin
                    uart_tx <= data_in_buf[5];
                    current_state <= B6;
                end
                
                B6: begin
                    uart_tx <= data_in_buf[6];
                    current_state <= B7;
                end
                
                B7: begin
                    uart_tx <= data_in_buf[7];
                    current_state <= CHECK;
                end
                
                CHECK: begin
                    // 使用SystemVerilog的异或归约运算符，即^
                    // 计算奇偶校验位
                    // uart_tx <= ^data_in_buf; // 发送奇偶校验位
                    uart_tx <= ^data_in_buf;
                    current_state <= STOP;
                end
                
                STOP: begin
                    uart_tx <= 1'b1;
                    uart_tx_done <= 1'b1;
                    current_state <= IDLE;
                end
                
                default: current_state <= IDLE;
            endcase
        end
    end

endmodule