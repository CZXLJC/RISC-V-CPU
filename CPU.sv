`timescale 1ns / 1ps

`include "Const.svh"
module CPU(
    input logic clk,
    input logic rst_n
);
    logic cpu_clk;
    logic mem_clk;


    
    // IF阶段信号
    logic [`DATA_WID] pc_curr;
    logic [`DATA_WID] old_pc;
    logic [`DATA_WID] inst;
    logic [`DATA_WID] predict_pc;  // 预测的下一PC值


    // IF/ID寄存器信号
    logic [`DATA_WID] if_id_inst;
    logic [`DATA_WID] if_id_pc_curr;

    // ID阶段信号
    logic [`DATA_WID] imm32;
    logic [`DATA_WID] rdata1, rdata2;
    logic [4:0]  rd;
    logic [`ALUCONTROL_WIDTH]  ALUControl;
    logic [`BRUCONTROL_WIDTH]  BRUControl;  // 分支控制信号
    logic        RegWrite, MemWrite, MemRead, MemtoReg, ALUSrc;
    logic        Jump;
    logic        Branch;  // 分支指令标志
    logic        BranchTaken;
    logic [`DATA_WID] BranchTarget;

    // ID/EX寄存器信号
    logic [`ALUCONTROL_WIDTH]  id_ex_ALUControl;
    logic [`BRUCONTROL_WIDTH]  id_ex_BRUControl;  // 分支控制信号
    logic        id_ex_RegWrite, id_ex_MemWrite, id_ex_MemRead, id_ex_MemtoReg, id_ex_ALUSrc;
    logic        id_ex_Branch;
    logic        id_ex_Jump;
    logic [`DATA_WID] id_ex_imm32, id_ex_rdata1, id_ex_rdata2;
    logic [4:0]  id_ex_rs1, id_ex_rs2;
    logic [4:0]  id_ex_rd;
    logic [`DATA_WID] id_ex_pc_curr;  // ID/EX寄存器传递的当前PC值
    
    // EX阶段信号
    logic [`DATA_WID] ex_ALUResult;  // EX阶段的ALU计算结果
    logic [4:0]  ex_rd;          // EX阶段的目标寄存器
    logic        ex_RegWrite;    // EX阶段的寄存器写使能

    // EX/MEM寄存器信号
    logic        ex_mem_RegWrite, ex_mem_MemWrite, ex_mem_MemRead, ex_mem_MemtoReg;
    logic [`DATA_WID] ex_mem_ALUResult, ex_mem_rdata2;
    logic [4:0]  ex_mem_rd;

    // MEM阶段信号
    logic [`DATA_WID] mem_rdata;  // 从DataMem读取的数据

    // MEM/WB寄存器信号
    logic        mem_wb_RegWrite, mem_wb_MemtoReg;
    logic [`DATA_WID] mem_wb_ALUResult, mem_wb_mem_rdata;
    logic [4:0]  mem_wb_rd;

    // WB阶段信号
    logic [`DATA_WID] wb_data;  // 写回寄存器的数据

    // 控制信号: 冒险检测
    logic Stall;  // 流水线阻塞信号
    logic Flush;  // 流水线冲刷信号
    logic Flush_id_ex;  // ID/EX寄存器冲刷信号
    logic [1:0] ForwardA, ForwardB;  // 前递信号

    assign Flush = (BranchTaken && (BranchTarget != predict_pc));
    // 异常处理信号
    logic        exception;
    logic [`DATA_WID] handler_pc;

    // 模块实例化
    Stage_IF #(.limit(32'b10000000)) u_Stage_IF (
        .clk(clk),
        .rst_n(rst_n),
        .BranchTaken(BranchTaken),
        .BranchTarget(BranchTarget),
        .Stall(Stall),  // 连接冒险检测的Stall信号
        .pc_curr(pc_curr),
        .old_pc(old_pc),
        .inst(inst),
        .predict_pc(predict_pc)  // 预测的下一PC值
    );

    IF_ID u_IF_ID (
        .clk(clk),
        .rst_n(rst_n),
        .Stall(Stall),  // 连接冒险检测的Stall信号
        .Flush(Flush), 
        .inst_in(inst),
        .pc_curr_in(old_pc), // 传递当前PC值
        .inst_out(if_id_inst),
        .pc_curr_out(if_id_pc_curr)  // 传递当前PC值
    );

    Stage_ID u_Stage_ID (
        .clk(clk),
        .rst_n(rst_n),
        .Stall(Stall),  // 连接冒险检测的Stall信号
        .inst(if_id_inst),
        .RegWrite_WB(mem_wb_RegWrite),  // 正确连接WB阶段的RegWrite
        .rd_WB(mem_wb_rd),              // 正确连接WB阶段的rd
        .write_data_WB(wb_data),        // 正确连接WB阶段的写回数据
        .imm32(imm32),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .rd(rd),
        .ALUControl(ALUControl),
        .BRUControl(BRUControl),  // 分支控制信号
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .Branch(Branch),  // 分支信号
        .Jump(Jump)
    );

    ID_EX u_ID_EX (
        .clk(clk),
        .rst_n(rst_n),
        .Stall(Stall),
        .Flush(Flush), 
        .pc_curr_in(if_id_pc_curr), // 传递当前PC值
        // 输入（来自ID阶段）
        .ALUControl_in(ALUControl),
        .BRUControl_in(BRUControl),  // 分支控制信号
        .RegWrite_in(RegWrite),
        .MemWrite_in(MemWrite),
        .MemRead_in(MemRead),
        .MemtoReg_in(MemtoReg),
        .ALUSrc_in(ALUSrc),
        .Branch_in(Branch),  // 分支信号
        .Jump_in(Jump),
        .imm32_in(imm32),
        .rdata1_in(rdata1),
        .rdata2_in(rdata2),
        .rd_in(rd),
        .rs1_in(u_Stage_ID.rs1),
        .rs2_in(u_Stage_ID.rs2),
        // 输出（到EX阶段）
        .ALUControl_out(id_ex_ALUControl),
        .BRUControl_out(id_ex_BRUControl),  // 分支控制信号
        .RegWrite_out(id_ex_RegWrite),
        .MemWrite_out(id_ex_MemWrite),
        .MemRead_out(id_ex_MemRead),
        .MemtoReg_out(id_ex_MemtoReg),
        .ALUSrc_out(id_ex_ALUSrc),
        .Branch_out(id_ex_Branch),  // 分支信号
        .Jump_out(id_ex_Jump),
        .imm32_out(id_ex_imm32),
        .rdata1_out(id_ex_rdata1),
        .rdata2_out(id_ex_rdata2),
        .rd_out(id_ex_rd),
        .rs1_out(id_ex_rs1),
        .rs2_out(id_ex_rs2),
        .pc_curr_out(id_ex_pc_curr)  // 传递当前PC值
    );

    Stage_EX u_Stage_EX (
        .pc_curr_ex(id_ex_pc_curr), // 传递当前PC值
        .ALUControl(id_ex_ALUControl),
        .BRUControl(id_ex_BRUControl),  // 分支控制信号
        .rdata1(id_ex_rdata1),
        .rdata2(id_ex_rdata2),
        .imm32(id_ex_imm32),
        .ALUSrc(id_ex_ALUSrc),
        .Branch(id_ex_Branch),
        .Jump(id_ex_Jump),
        .ALUResult(ex_ALUResult),
        .BranchTarget(BranchTarget),
        .BranchTaken(BranchTaken)
        ,
        .forward_data_ex_mem(ex_mem_ALUResult),
        .forward_data_mem_wb(wb_data),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
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
        .addra(ex_mem_ALUResult>>2), // 地址（14位地址线）
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
        .rs1_ex(id_ex_rs1),
        .rs2_ex(id_ex_rs2),
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
        .Stall(Stall)
    );

endmodule


