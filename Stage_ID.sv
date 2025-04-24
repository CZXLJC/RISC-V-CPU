`timescale 1ns / 1ps

`include "Const.svh"
module Stage_ID(
    // 基础信号
    input  logic        clk,
    input  logic        rst_n,
    input  logic        Stall,        // 流水线阻塞信号，在当前模块用于清刷控制信号
    // 来自IF阶段的数据
    input  logic [`DATA_WID] inst,         // 指令
    // 来自WB阶段的写回信号
    input  logic        RegWrite_WB,  // WB阶段的寄存器写使能
    input  logic [4:0]  rd_WB,        // WB阶段的目标寄存器
    input  logic [`DATA_WID] write_data_WB,// WB阶段的写回数据

    // 前递信号
    // input  logic [`DATA_WID] forward_data_ex_mem,  // EX/MEM阶段前递数据
    // input  logic [`DATA_WID] forward_data_mem_wb,  // MEM/WB阶段前递数据
    // input  logic [1:0]  ForwardA,             // rs1前递选择
    // input  logic [1:0]  ForwardB,              // rs2前递选择

    // 输出到EX阶段的信号
    output logic [`DATA_WID] imm32,        // 生成的立即数
    output logic [`DATA_WID] rdata1,       // 寄存器1数据
    output logic [`DATA_WID] rdata2,       // 寄存器2数据
    output logic [4:0]  rd,           // 目标寄存器
    output logic [`ALUCONTROL_WIDTH]  ALUControl,   // ALU控制信号
    output logic [`BRUCONTROL_WIDTH]  BRUControl,   // 分支控制信号
    output logic        RegWrite,     // 寄存器写使能
    output logic        MemWrite,     // 存储器写使能
    output logic        MemRead,      // 存储器读使能
    output logic        MemtoReg,     // 存储器到寄存器
    output logic        ALUSrc,       // ALU操作数来源
    output logic        Branch,       // 分支指令标志
    output logic        Jump
);

    // logic [`DATA_WID] rdata1_temp, rdata2_temp; // 寄存器数据临时变量

    //-----------------------------
    // 内部信号和模块实例化
    //-----------------------------
    // 解析指令字段
    logic [6:0]  opcode;
    logic [4:0]  rs1, rs2;
    logic [2:0]  funct3;
    logic        funct7;
    logic        Mfunct7; // M 拓展指令指示信号
    logic [1:0]  ALUOp;

    assign opcode = inst[6:0];
    assign rs1    = inst[19:15];
    assign rs2    = inst[24:20];
    assign funct3 = inst[14:12];
    assign funct7 = inst[30];
    assign Mfunct7 = inst[25]; // M拓展指令的funct7位
    assign rd     = inst[11:7];
    assign BRUControl = funct3; // 分支控制信号

    // 控制器模块
    Controller u_Controller (
        .opcode(opcode),
        .Stall(Stall),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp),
        .Branch(Branch),
        .Jump(Jump)
    );

    // 寄存器文件模块
    Registers u_Registers (
        .clk(clk),
        .rst_n(rst_n),
        .RegWrite(RegWrite_WB),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd_WB),
        .writeData(write_data_WB),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    // 立即数生成模块
    ImmGen u_ImmGen (
        .instruction(inst),
        .imm32(imm32)
    );

    // ALU控制器模块
    ALUController u_ALUController (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .Mfunct7(Mfunct7),
        .ALUControl(ALUControl)
    );

    // 前递逻辑处理
    // always_comb begin
    //     // 前递数据选择
    //     case (ForwardA)
    //         2'b00: rdata1 = rdata1_temp; // 无前递
    //         2'b01: rdata1 = forward_data_ex_mem; // EX/MEM前递
    //         2'b10: rdata1 = forward_data_mem_wb; // MEM/WB前递
    //         default: rdata1 = rdata1_temp; // 默认值
    //     endcase

    //     case (ForwardB)
    //         2'b00: rdata2 = rdata2_temp; // 无前递
    //         2'b01: rdata2 = forward_data_ex_mem; // EX/MEM前递
    //         2'b10: rdata2 = forward_data_mem_wb; // MEM/WB前递
    //         default: rdata2 = rdata2_temp; // 默认值
    //     endcase
    // end
endmodule