`timescale 1ns/1ps

`include "define.v"

module openriscv_min_sopc(
    (* DONT_TOUCH = "TRUE" *) input wire          clk,
    input wire          rst_n,

    output[6:0]         a_to_g_0,//数码管段选信号（第一组，a-g 七个段）
    output[6:0]         a_to_g_1,//数码管段选信号（第二组，a-g 七个段）
    output[7:0]         an//数码管位选信号（共阴极数码管，共阳极数码管为高电平）
);

    //连接指令存储器
   (* DONT_TOUCH = "TRUE" *) wire[`InstAddrBus]     inst_addr;//指令地址
   (* DONT_TOUCH = "TRUE" *) wire[`InstBus]         inst;//指令数据
   (* DONT_TOUCH = "TRUE" *) wire                   rom_ce; //ROM 芯片使能信号

   (* DONT_TOUCH = "TRUE" *) wire[`DataBus]         ram_data_o;    //从CPU输出到RAM
   (* DONT_TOUCH = "TRUE" *) wire[`DataBus]         ram_data_i;    //从RAM输入到CPU
   (* DONT_TOUCH = "TRUE" *) wire[`DataAddrBus]     ram_addr;
   (* DONT_TOUCH = "TRUE" *) wire                   ce;
   (* DONT_TOUCH = "TRUE" *) wire                   we;//RAM写使能
   (* DONT_TOUCH = "TRUE" *) wire[`RegBus]          display_reg;
   (* DONT_TOUCH = "TRUE" *) wire                   rst;

   assign rst = ~rst_n;
   //assign rst = rst_n;

    //例化处理器OpenRISC-V
    openriscv openriscv0(
        .clk(clk),
        .rst(rst),
        .rom_addr_o(inst_addr),
        .rom_data_i(inst),
        .rom_ce_o(rom_ce),

        .ram_addr_o(ram_addr),
        .ram_data_o(ram_data_o),
        .ram_data_i(ram_data_i),
        .ram_ce_o(ce),
        .ram_we_o(we),
        .display_reg(display_reg)
    );

    //例化指令存储器ROM
    inst_rom inst_rom0(
        .addr(inst_addr),
        .inst(inst),
        .ce(rom_ce),
        .rst(rst)
    );

    //例化数据存储器RAM
    data_ram data_ram0(
        .clk(clk),
        .addr(ram_addr),
        .data_o(ram_data_i),
        .data_i(ram_data_o),
        .ce(ce),
        .we(we)
    );

    //例化数码管驱动模块
    x7seg_top x7seg_top0(
        .clk(clk),
        .rst(rst_n),
        .data_i(display_reg),
        .a_to_g_0(a_to_g_0),
        .a_to_g_1(a_to_g_1),
        .an(an)
    );

endmodule