// 指令集架构常量定义
`define DATA_WID 31:0 // 数据位宽
`define REG_ID_WID 4:0 // 寄存器ID位宽
`define R_TYPE 7'b0110011 // R型指令操作码
// you can do it!

// ALU常量定义
`define ALUCONTROL_WIDTH 4:0 // ALU控制信号位宽
`define ADD 5'b00000 // ALU加法操作
`define SUB 5'b01000 // ALU减法操作
// todo: 其他操作码定义


// BRU常量定义
`define BRUCONTROL_WIDTH 2:0 // BRU控制信号位宽
`define BEQ 3'b000 // BEQ指令
`define BNE 3'b001 // BNE指令
// todo: 其他分支指令定义


