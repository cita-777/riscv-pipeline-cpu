`timescale 1ns/1ps

`include "define.v"

module inst_rom(
    input wire                  rst,
    input wire                  ce,
    (* DONT_TOUCH = "TRUE" *) input wire[`InstAddrBus]    addr,
    output reg[`InstBus]        inst
);

    // 斐波那契程序的常量ROM（与 inst_rom.txt 一致）
    // 说明：inst_rom.txt 里的每行是按字节反序存放（如 93001000 对应指令 00100093），
    //       所以这里保持同样格式，输出时再做一次字节翻转。
    reg[`InstBus] inst_raw;

    always @(*) begin
        if (rst == `RstEnable) begin
            inst <= `ZeroWord;
        end else if (ce == `ChipDisable) begin
            inst <= `ZeroWord;
        end else begin
            //寻址是按照字节的，但是指令是按照字的，所以要除以4（右移两位）。
            case (addr[`InstMemNumLog2+1:2])
                11'd0: inst_raw = 32'h93001000; // addi x1, x0, 1
                11'd1: inst_raw = 32'h13011000; // addi x2, x0, 1
                11'd2: inst_raw = 32'h93011000; // addi x3, x0, 1
                11'd3: inst_raw = 32'h13054006; // addi x10, x0, 100
                11'd4: inst_raw = 32'hb3812000; // add  x3, x1, x2
                11'd5: inst_raw = 32'h93000100; // addi x1, x2, 0
                11'd6: inst_raw = 32'h13810100; // addi x2, x3, 0
                11'd7: inst_raw = 32'he3eaa1fe; // bltu x3, x10, -12
                11'd8: inst_raw = 32'h9301703e; // addi x3, x0, 999
                default: inst_raw = 32'h00000000;
            endcase

            // inst_raw 为字节反序存储，这里翻转为CPU实际指令
            inst <= {inst_raw[7:0], inst_raw[15:8], inst_raw[23:16], inst_raw[31:24]};
        end
    end

endmodule