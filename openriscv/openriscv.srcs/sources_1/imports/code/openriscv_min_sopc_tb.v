//==============================================================================
// 文件名: openriscv_min_sopc_tb.v
// 功能描述: 仿真测试平台，验证 CPU 功能正确性
//==============================================================================
`include "define.v"

`timescale 1ns/1ps

module openriscv_min_sopc_tb();
    
    reg CLOCK_50;
    reg rst;

// ********** 时钟生成 **********

    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;  //50MHz时钟，周期20ns
    end

// ********** 复位与仿真控制 **********

    initial begin
        rst = `RstEnable;           //初始复位
        #95 rst = `RstDisable;      //95ns后释放复位
        #3000 $finish;              //仿真运行3000ns后结束
    end

    openriscv_min_sopc openriscv_min_sopc0(
        .clk(CLOCK_50),
        .rst_n(rst)
    );

endmodule