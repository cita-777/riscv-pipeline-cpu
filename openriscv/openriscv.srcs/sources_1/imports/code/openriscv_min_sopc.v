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
    wire[`RegBus]                                   reg3_debug_cpu;
    reg[`RegBus]                                    reg3_dbg_sync1;
    reg[`RegBus]                                    reg3_dbg_sync2;
    wire[`RegBus]                                   reg3_dbg_ila;
   (* DONT_TOUCH = "TRUE" *) wire                   rst;

    // 复位信号：板上按键为高有效（ILA 实测：按下时 rst_n=1）。
    // 设计内部统一使用高有效 rst。
    assign rst = rst_n;

   // ========= CPU 降频时钟 =========
   // 说明：实现报告显示 50MHz 下存在较大负裕量，硬件上可能出现“仿真正常/板上异常”。
   // 这里把 CPU 与 data_ram 跑在更低频率（默认 50MHz / 8 = 6.25MHz），
   // 数码管扫描仍使用原始 50MHz，避免刷新闪烁。
   reg [2:0] cpu_clk_div;
   reg       cpu_clk;

   always @(posedge clk) begin
       if (rst == 1'b1) begin
           cpu_clk_div <= 3'd0;
           cpu_clk <= 1'b0;
       end else begin
           if (cpu_clk_div == 3'd3) begin
               cpu_clk_div <= 3'd0;
               cpu_clk <= ~cpu_clk;
           end else begin
               cpu_clk_div <= cpu_clk_div + 3'd1;
           end
       end
   end

   // ========= ILA 观测信号同步（CPU 域 -> clk 域）=========
   // cpu_clk 由 clk 分频得到，二者同源；reg3 在 cpu_clk 域更新，
   // 这里做两级采样，保证 ILA 采样域看到稳定值。
   always @(posedge clk) begin
       if (rst == 1'b1) begin
           reg3_dbg_sync1 <= `ZeroWord;
           reg3_dbg_sync2 <= `ZeroWord;
       end else begin
           reg3_dbg_sync1 <= reg3_debug_cpu;
           reg3_dbg_sync2 <= reg3_dbg_sync1;
       end
   end
   assign reg3_dbg_ila = reg3_dbg_sync2;

    //例化处理器OpenRISC-V
    openriscv openriscv0(
        .clk(cpu_clk),
        .rst(rst),
        .rom_addr_o(inst_addr),
        .rom_data_i(inst),
        .rom_ce_o(rom_ce),

        .ram_addr_o(ram_addr),
        .ram_data_o(ram_data_o),
        .ram_data_i(ram_data_i),
        .ram_ce_o(ce),
        .ram_we_o(we),
        .display_reg(display_reg),
        .reg3_debug_o(reg3_debug_cpu)
    );

    // ========= ILA 实例化 =========
    ila_0 ila_0_inst(
        .clk(clk),
        .probe0(rst),
        .probe1(cpu_clk),
        .probe2(reg3_dbg_ila)
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
        .clk(cpu_clk),
        .addr(ram_addr),
        .data_o(ram_data_i),
        .data_i(ram_data_o),
        .ce(ce),
        .we(we)
    );

    //例化数码管驱动模块
    x7seg_top x7seg_top0(
        .clk(clk),
        .rst(rst),
        .data_i(display_reg),
        .a_to_g_0(a_to_g_0),
        .a_to_g_1(a_to_g_1),
        .an(an)
    );

endmodule