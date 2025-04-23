`timescale 1ns / 1ps

// 处理读取后的执行冲突，用于阻塞和冲刷
module HazardDetection(
    // 来自ID阶段的指令信息
    input  logic [4:0] rs1_id,
    input  logic [4:0] rs2_id,
    // 来自EX阶段的指令类型
    input  logic       MemRead_ex,
    input  logic [4:0] rd_ex,

    // DCache信号
    // input  logic       Hit,

    // 输出控制信号
    output logic       Stall,    // 阻塞流水线
    output logic       Flush_id_ex
    // , // 冲刷ID/EX寄存器
    // output logic       Flush     
);
    always_comb begin
        // Load-Use冒险检测
        // 如果EX阶段的指令是Load指令，并且ID阶段的rs1或rs2与EX阶段的rd相同，则需要插入气泡
        // if (Hit) begin
        //     Stall = 1'b0;  // 不阻塞流水线
        //     Flush_id_ex = 1'b0;  // 无需冲刷ID/EX寄存器
        // end
        // else 
        if (MemRead_ex && ((rd_ex == rs1_id) || (rd_ex == rs2_id))) begin
            Stall = 1'b1;  // 插入气泡，阻塞流水线
            Flush_id_ex = 1'b1;  // 冲刷ID/EX寄存器
        end
        else begin
            Stall = 1'b0;
            Flush_id_ex = 1'b0;  // 无需阻塞或冲刷
        end
    end
endmodule