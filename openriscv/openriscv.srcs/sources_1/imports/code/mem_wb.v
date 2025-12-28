//==============================================================================
// 文件名: mem_wb.v
// 功能描述: MEM/WB 流水线寄存器，传递访存结果到写回阶段
//==============================================================================
`timescale 1ns/1ps

`include "define.v"

module mem_wb(
    input wire              clk,
    input wire              rst,

    //访存阶段的结果
    input wire[`RegAddrBus] mem_wd,
    input wire              mem_wreg,
    input wire[`RegBus]     mem_wdata,

    input wire[5:0]         stall,

    //送到回写阶段的信息
    output reg[`RegAddrBus] wb_wd,
    output reg              wb_wreg,
    output reg[`RegBus]     wb_wdata
);

// ********** 流水线寄存器传递逻辑 **********

    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            //复位时清零所有输出
            wb_wd      <= `NOPRegAddr;
            wb_wreg    <= `WriteDisable;
            wb_wdata   <= `ZeroWord;
        end else if (stall[4] == `Stop && stall[5] == `NoStop) begin
            //MEM暂停而WB不暂停时，插入空泡
            wb_wd      <= `NOPRegAddr;
            wb_wreg    <= `WriteDisable;
            wb_wdata   <= `ZeroWord;
        end else if (stall[4] == `NoStop) begin
            //正常情况下传递数据
            wb_wd      <= mem_wd;
            wb_wreg    <= mem_wreg;
            wb_wdata   <= mem_wdata;
        end
        //stall[4]==Stop时保持不变
    end

endmodule