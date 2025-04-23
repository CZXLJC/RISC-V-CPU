`timescale 1ns / 1ps


`include "Const.svh"
module CPU(
    input logic clk,
    input logic rst_n
);
    // IF阶段信号
    logic [31:0] pc_curr;
    logic [31:0] inst;
    logic [31:0] pc_plus4;
    logic [31:0] predict_pc;  // 预测的下一PC值


    // IF/ID寄存器信号
    logic [31:0] if_id_inst;
    logic [31:0] if_id_pc_plus4;

    // ID阶段信号
    logic [31:0] imm32;
    logic [31:0] rdata1, rdata2;
    logic [4:0]  rd;
    logic [`ALUCONTROL_WIDTH]  ALUControl;
    logic        RegWrite, MemWrite, MemRead, MemtoReg, ALUSrc;
    logic        Jump;
    logic        BranchTaken;
    logic [31:0] BranchTarget;

    // ID/EX寄存器信号
    logic [`ALUCONTROL_WIDTH]  id_ex_ALUControl;
    logic        id_ex_RegWrite, id_ex_MemWrite, id_ex_MemRead, id_ex_MemtoReg, id_ex_ALUSrc;
    logic [31:0] id_ex_imm32, id_ex_rdata1, id_ex_rdata2;
    logic [4:0]  id_ex_rd;
    
    // EX阶段信号
    logic [31:0] ex_ALUResult;  // EX阶段的ALU计算结果
    logic [4:0]  ex_rd;          // EX阶段的目标寄存器
    logic        ex_RegWrite;    // EX阶段的寄存器写使能

    // EX/MEM寄存器信号
    logic        ex_mem_RegWrite, ex_mem_MemWrite, ex_mem_MemRead, ex_mem_MemtoReg;
    logic [31:0] ex_mem_ALUResult, ex_mem_rdata2;
    logic [4:0]  ex_mem_rd;

    // MEM阶段信号
    logic [31:0] mem_rdata;  // 从DataMem读取的数据

    // MEM/WB寄存器信号
    logic        mem_wb_RegWrite, mem_wb_MemtoReg;
    logic [31:0] mem_wb_ALUResult, mem_wb_mem_rdata;
    logic [4:0]  mem_wb_rd;

    // WB阶段信号
    logic [31:0] wb_data;  // 写回寄存器的数据

    // 控制信号: 前递与冒险检测
    logic Stall;  // 流水线阻塞信号
    logic Flush;  // 流水线冲刷信号
    logic Flush_id_ex;  // ID/EX寄存器冲刷信号
    logic [1:0] ForwardA, ForwardB;  // 前递信号

    assign Flush = (BranchTaken && (BranchTarget != predict_pc));
    //  || Flush_id_ex;  // 分支预测错误时冲刷流水线

    // 异常处理信号
    logic        exception;
    logic [31:0] handler_pc;

    // 模块实例化
    Stage_IF u_Stage_IF (
        .clk(clk),
        .rst_n(rst_n),
        .BranchTaken(BranchTaken),
        .BranchTarget(BranchTarget),
        .Stall(Stall),  // 连接冒险检测的Stall信号
        .pc_curr(pc_curr),
        .inst(inst),
        .pc_plus4(pc_plus4),
        .predict_pc(predict_pc)  // 预测的下一PC值
    );

    IF_ID u_IF_ID (
        .clk(clk),
        .rst_n(rst_n),
        // .Stall(Stall),  // 连接冒险检测的Stall信号
        .Flush(Flush),  // 连接冒险检测的Flush信号
        .inst_in(inst),
        .pc_plus4_in(pc_plus4),
        .inst_out(if_id_inst),
        .pc_plus4_out(if_id_pc_plus4)
    );

    Stage_ID u_Stage_ID (
        .clk(clk),
        .rst_n(rst_n),
        .inst(if_id_inst),
        .pc_plus4(if_id_pc_plus4),
        .RegWrite_WB(mem_wb_RegWrite),  // 正确连接WB阶段的RegWrite
        .rd_WB(mem_wb_rd),              // 正确连接WB阶段的rd
        .write_data_WB(wb_data),        // 正确连接WB阶段的写回数据
        .imm32(imm32),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .rd(rd),
        .ALUControl(ALUControl),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .BranchTaken(BranchTaken),
        .BranchTarget(BranchTarget),
        .forward_data_ex_mem(ex_mem_ALUResult),
        .forward_data_mem_wb(wb_data),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    ID_EX u_ID_EX (
        .clk(clk),
        .rst_n(rst_n),
        .Flush(Flush),  // 连接冒险检测的Flush信号
        // 输入（来自ID阶段）
        .ALUControl_in(ALUControl),
        .RegWrite_in(RegWrite),
        .MemWrite_in(MemWrite),
        .MemRead_in(MemRead),
        .MemtoReg_in(MemtoReg),
        .ALUSrc_in(ALUSrc),
        .imm32_in(imm32),
        .rdata1_in(rdata1),
        .rdata2_in(rdata2),
        .rd_in(rd),
        // 输出（到EX阶段）
        .ALUControl_out(id_ex_ALUControl),
        .RegWrite_out(id_ex_RegWrite),
        .MemWrite_out(id_ex_MemWrite),
        .MemRead_out(id_ex_MemRead),
        .MemtoReg_out(id_ex_MemtoReg),
        .ALUSrc_out(id_ex_ALUSrc),
        .imm32_out(id_ex_imm32),
        .rdata1_out(id_ex_rdata1),
        .rdata2_out(id_ex_rdata2),
        .rd_out(id_ex_rd)
    );

    Stage_EX u_Stage_EX (
        .ALUControl(id_ex_ALUControl),
        .rdata1(id_ex_rdata1),
        .rdata2(id_ex_rdata2),
        .imm32(id_ex_imm32),
        .ALUSrc(id_ex_ALUSrc),
        .ALUResult(ex_ALUResult)
    );

    EX_MEM u_EX_MEM (
        .clk(clk),
        .rst_n(rst_n),
        // 输入（来自EX阶段）
        .RegWrite_in(id_ex_RegWrite),
        .MemWrite_in(id_ex_MemWrite),
        .MemRead_in(id_ex_MemRead),
        .MemtoReg_in(id_ex_MemtoReg),
        .ALUResult_in(ex_ALUResult),
        .rdata2_in(id_ex_rdata2),
        .rd_in(id_ex_rd),
        // 输出（到MEM阶段）
        .RegWrite_out(ex_mem_RegWrite),
        .MemWrite_out(ex_mem_MemWrite),
        .MemRead_out(ex_mem_MemRead),
        .MemtoReg_out(ex_mem_MemtoReg),
        .ALUResult_out(ex_mem_ALUResult),
        .rdata2_out(ex_mem_rdata2),
        .rd_out(ex_mem_rd)
    );

    Stage_MEM u_Stage_MEM (
        // 控制信号
        .MemWrite(ex_mem_MemWrite),
        .MemRead(ex_mem_MemRead),
        // 数据信号
        .ALUResult(ex_mem_ALUResult),
        .rdata2(ex_mem_rdata2),
        // 存储器接口
        .mem_rdata(mem_rdata)  // 直接连接DataMem输出
    );

    DataMem u_DataMem (
        .clka(clk),
        .wea(ex_mem_MemWrite),           // 写使能
        .addra(ex_mem_ALUResult[13:0]>>2), // 地址（14位地址线）
        .dina(ex_mem_rdata2),            // 写入数据
        .douta(mem_rdata)               // 读取数据
    );

    MEM_WB u_MEM_WB (
        .clk(clk),
        .rst_n(rst_n),
        // 输入（来自MEM阶段）
        .RegWrite_in(ex_mem_RegWrite),
        .MemtoReg_in(ex_mem_MemtoReg),
        .ALUResult_in(ex_mem_ALUResult),
        .mem_rdata_in(mem_rdata),
        .rd_in(ex_mem_rd),
        // 输出（到WB阶段）
        .RegWrite_out(mem_wb_RegWrite),
        .MemtoReg_out(mem_wb_MemtoReg),
        .ALUResult_out(mem_wb_ALUResult),
        .mem_rdata_out(mem_wb_mem_rdata),
        .rd_out(mem_wb_rd)
    );

    Stage_WB u_Stage_WB (
        .MemtoReg(mem_wb_MemtoReg),
        .ALUResult(mem_wb_ALUResult),
        .mem_rdata(mem_wb_mem_rdata),
        .wb_data(wb_data)
    );

    // 前递单元实例化
    ForwardingUnit u_ForwardingUnit (
        .rs1_id(u_Stage_ID.rs1),
        .rs2_id(u_Stage_ID.rs2),
        .rd_ex_mem(ex_mem_rd),
        .RegWrite_ex_mem(ex_mem_RegWrite),
        .rd_mem_wb(mem_wb_rd),
        .RegWrite_mem_wb(mem_wb_RegWrite),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    // 冒险检测单元实例化
    HazardDetection u_HazardDetection (
        .rs1_id(u_Stage_ID.rs1),
        .rs2_id(u_Stage_ID.rs2),
        .MemRead_ex(id_ex_MemRead),
        .rd_ex(id_ex_rd),
        .Stall(Stall),
        // .Flush(Flush)
        .Flush_id_ex(Flush_id_ex)
    );

    // 实例化异常检测模块
    ExceptionHandler u_ExceptionHandler (
        .pc(pc_curr),
        .inst(inst),
        .mem_addr(ex_mem_ALUResult),  // MEM阶段地址
        .mem_write(ex_mem_MemWrite),
        .mem_read(ex_mem_MemRead),
        .exception(exception),
        .handler_pc(handler_pc)
    );

    // 异常处理逻辑（冲刷流水线并跳转）
    // assign BranchTaken = exception || BranchTaken;  // 异常优先
    // assign BranchTarget = exception ? handler_pc : BranchTarget;

endmodule