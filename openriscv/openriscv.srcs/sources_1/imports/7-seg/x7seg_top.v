//==============================================================================
// 文件名: x7seg_top.v
// 功能描述: 数码管顶层模块，驱动 8 位数码管显示 32 位数据
//==============================================================================
`timescale 1ns/1ps

module x7seg_top(
    input wire          clk,
    input wire          rst,
    input wire[31:0]    data_i,
    output[6:0]         a_to_g_0,
    output[6:0]         a_to_g_1,
    output[7:0]         an
);

    //低16位数据显示（右侧4个数码管）
    x7seg X1(
        .x(data_i[15:0]),
        .clk(clk),
        .rst(rst),
        .a_to_g(a_to_g_0),
        .an(an[3:0])
    );
    //高16位数据显示（左侧4个数码管）
    x7seg X2(
        .x(data_i[31:16]),
        .clk(clk),
        .rst(rst),
        .a_to_g(a_to_g_1),
        .an(an[7:4])
    );

endmodule
