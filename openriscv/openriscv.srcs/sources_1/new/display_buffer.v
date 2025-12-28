`timescale 1ns/1ps

`include "define.v"

module display_buffer(
    input wire                  clk,
    input wire                  rst,
    input wire[`RegBus]         reg1,
    output reg[`RegBus]         display_reg1
);

    localparam integer BUF_DEPTH = 21;
    // 50MHz 下约 1 秒刷新一次；如板上时钟不同可调整
    localparam integer WAIT_CYCLES = 50_000_000;

    reg[`RegBus]    reg1_buf[0:BUF_DEPTH-1];
    reg[4:0]        counter_i;
    reg[4:0]        counter_o;
    reg[`RegBus]    last_reg1;
    reg[31:0]       wait_counter;

    integer j;

    // CPU 时钟域 -> 显示时钟域 同步/稳定性滤波
    reg[`RegBus] reg1_sync1;
    reg[`RegBus] reg1_sync2;
    reg[`RegBus] reg1_sync3;
    wire[`RegBus] reg1_s;
    assign reg1_s = reg1_sync3;

    // 同步采样与输出（避免组合写 RAM/锁存器导致综合后行为漂移）
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            counter_i <= 5'd0;
            counter_o <= 5'd0;
            last_reg1 <= `ZeroWord;
            wait_counter <= 32'd0;
            display_reg1 <= `ZeroWord;
            reg1_sync1 <= `ZeroWord;
            reg1_sync2 <= `ZeroWord;
            reg1_sync3 <= `ZeroWord;
            for (j = 0; j < BUF_DEPTH; j = j + 1) begin
                reg1_buf[j] <= `ZeroWord;
            end
        end else begin
            reg1_sync1 <= reg1;
            reg1_sync2 <= reg1_sync1;
            reg1_sync3 <= reg1_sync2;

            // 记录 reg1 的变化序列
            // 额外要求连续两拍稳定，降低多位总线跨域采样的抖动概率
            if ((reg1_sync2 == reg1_sync3) && (reg1_s != last_reg1) && (counter_i < BUF_DEPTH[4:0])) begin
                // 999(0x3E7) 作为程序结束标记：不写入显示缓冲，否则输出端可能卡死
                if (reg1_s != 32'h000003E7) begin
                    reg1_buf[counter_i] <= reg1_s;
                    counter_i <= counter_i + 5'd1;
                end
                last_reg1 <= reg1_s;
            end

            // 定时把缓冲内容送到数码管
            if (wait_counter >= (WAIT_CYCLES - 1)) begin
                wait_counter <= 32'd0;
                if (counter_o < counter_i) begin
                    if (reg1_buf[counter_o] != 32'h000003E7) begin
                        display_reg1 <= reg1_buf[counter_o];
                    end
                    // 无论是否为结束标记，都前进，避免卡在同一个位置
                    counter_o <= counter_o + 5'd1;
                end
            end else begin
                wait_counter <= wait_counter + 32'd1;
            end
        end
    end

endmodule
