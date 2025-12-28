//==============================================================================
// 文件名: id_ex.v
// 功能描述: ID/EX 流水线寄存器，传递译码结果到执行阶段
//==============================================================================
`timescale 1ns/1ps

`include "define.v"

module id_ex(
    input wire                  clk,
    input wire                  rst,
    input wire[`RegBus]         id_reg1,
    input wire[`RegBus]         id_reg2,
    input wire[`RegAddrBus]     id_wd,
    input wire                  id_wreg,
    input wire[`InstBus]        id_inst,
    input wire[5:0]             stall,

    //传递到执行阶段的信息
    output reg[`RegBus]         ex_reg1,
    output reg[`RegBus]         ex_reg2,
    output reg[`RegAddrBus]     ex_wd,
    output reg                  ex_wreg,
    output reg[`InstBus]        ex_inst
);

// ********** 流水线寄存器传递逻辑 **********

    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            //复位时清零所有输出
            ex_reg1         <= `ZeroWord;
            ex_reg2         <= `ZeroWord;
            ex_wd           <= `NOPRegAddr;
            ex_wreg         <= `WriteDisable;
            ex_inst         <= `EXE_NOP;
        end else if (stall[2] == `Stop && stall[3] == `NoStop) begin
            //ID暂停而EX不暂停时，插入空泡
            ex_reg1         <= `ZeroWord;
            ex_reg2         <= `ZeroWord;
            ex_wd           <= `NOPRegAddr;
            ex_wreg         <= `WriteDisable;
            ex_inst         <= `EXE_NOP;
        end else if (stall[2] == `NoStop) begin
            //正常情况下传递数据
            ex_reg1         <= id_reg1;
            ex_reg2         <= id_reg2;
            ex_wd           <= id_wd;
            ex_wreg         <= id_wreg;
            ex_inst         <= id_inst;
        end
        //stall[2]==Stop时保持不变
    end

endmodule