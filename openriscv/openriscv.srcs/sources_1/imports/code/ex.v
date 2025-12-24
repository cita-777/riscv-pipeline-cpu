`timescale 1ns/1ps

`include "define.v"

module ex(
    input wire                  rst,

    //译码阶段传递到执行阶段的信息
    input wire[`RegBus]         reg1_i,
    input wire[`RegBus]         reg2_i,
    input wire[`RegAddrBus]     wd_i,
    input wire                  wreg_i,
    input wire[`InstBus]        inst_i,

    //执行的结果
    output reg[`RegAddrBus]     wd_o,        //写回寄存器地址
    output reg                  wreg_o,      //写使能
    output reg[`RegBus]         wdata_o,     //写回数据

    output reg[6:0]             opcode_o,
    output reg[2:0]             funct3_o,
    output reg[`RegBus]         mem_addr_o,
    output reg[`RegBus]         mem_data_o,
    output wire[1:0]            mem_rindex_o,
    output wire[1:0]            mem_windex_o,

    output reg                  is_load_o,      //当前指令是否为load指令，用于传入id模块以实现流水线暂停

    //流水线暂停信号
    output wire                 stall_req_from_ex
);

    //保存逻辑运算的结果
    reg[`RegBus] logicout;

    wire[6:0] opcode;
    wire[2:0] funct3;
    wire[6:0] funct7;
    wire[4:0] rd;

    wire[31:0] op1_add_op2;
    wire[31:0] op1_subtract_op2;
    wire[31:0] op1_greater_than_op2_singned;
    wire[31:0] op1_greater_than_op2_unsigned;

    assign opcode = inst_i[6:0];
    assign funct3 = inst_i[14:12];
    assign funct7 = inst_i[31:25];
    assign rd     = inst_i[11:7];

    //有符号数比较
    assign op1_greater_than_op2_singned     =   ($signed(reg1_i) >= $signed(reg2_i));
    //无符号数比较
    assign op1_greater_than_op2_unsigned    =   (reg1_i >= reg2_i);
    
    assign op1_add_op2                      =   reg1_i + reg2_i;        //相加
    assign op1_subtract_op2                 =   reg1_i - reg2_i;        //相减

    assign mem_rindex_o = (reg1_i + {{20{inst_i[31]}}, inst_i[31:20]}) & 2'b11;
    assign mem_windex_o = (reg1_i + {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]}) & 2'b11;

    assign stall_req_from_ex = `NoStop;

    always @(*) begin
        wreg_o <= wreg_i;
        wd_o   <= wd_i;
        wdata_o <= `ZeroWord;

        opcode_o <= opcode;
        funct3_o <= funct3;
        mem_addr_o <= `ZeroWord;
        mem_data_o <= `ZeroWord;
        is_load_o <= 1'b0;
        case(opcode)
            `INST_TYPE_I: begin
                case(funct3)
                    `EXE_ADDI: begin
                        wdata_o <= op1_add_op2;
                        wd_o    <= rd;
                    end
                    `EXE_ORI: begin
                        wdata_o <= reg1_i | reg2_i;
                        wd_o    <= rd;
                    end
                    `EXE_ANDI: begin
                        wdata_o <= reg1_i & reg2_i;
                        wd_o    <= rd;
                    end
                    `EXE_XORI: begin
                        wdata_o <= reg1_i ^ reg2_i;
                        wd_o    <= rd;
                    end
                    `EXE_SLTI: begin
                        //注意这里是对大于等于取反了，也就是小于。然后进行符号扩展。
                        //SLTIU SLT SLTU与此相同
                        wdata_o <= {32{(~op1_greater_than_op2_singned)}} & 32'h1;
                        wd_o    <= rd;
                    end
                    `EXE_SLTIU: begin
                        wdata_o <= {32{(~op1_greater_than_op2_unsigned)}} & 32'h1;
                        wd_o    <= rd;
                    end
                    `EXE_SLLI: begin
                        wdata_o <= reg1_i << reg2_i[4:0];
                        wd_o    <= rd;
                    end
                    `EXE_SRLI: begin
                        // SRLI 和 SRAI 共用 funct3=3'b101，通过 funct7[5] 区分
                        if (funct7[5] == 1'b0) begin
                            wdata_o <= reg1_i >> reg2_i[4:0];           // SRLI 逻辑右移
                        end else begin
                            wdata_o <= $signed(reg1_i) >>> reg2_i[4:0]; // SRAI 算术右移
                        end
                        wd_o    <= rd;
                    end
                    default: begin
                        wdata_o <= `ZeroWord;
                        wd_o    <= `NOPRegAddr;
                    end
                endcase
            end
            `INST_TYPE_R: begin
                // RV32M 指令通过 funct7=0000001 与普通 R 型指令互斥区分
                if (funct7 == `FUNCT7_MULDIV) begin
                    case (funct3)
                        `EXE_MUL:    wdata_o <= reg1_i * reg2_i;  // 低32位
                        `EXE_MULH:   wdata_o <= (($signed({{32{reg1_i[31]}}, reg1_i}) * $signed({{32{reg2_i[31]}}, reg2_i})) >> 32);
                        `EXE_MULHSU: wdata_o <= (($signed({{32{reg1_i[31]}}, reg1_i}) * {{32{1'b0}}, reg2_i}) >> 32);
                        `EXE_MULHU:  wdata_o <= (({{32{1'b0}}, reg1_i} * {{32{1'b0}}, reg2_i}) >> 32);
                        `EXE_DIV:    wdata_o <= (reg2_i == 0) ? 32'hFFFFFFFF : $signed(reg1_i) / $signed(reg2_i);
                        `EXE_DIVU:   wdata_o <= (reg2_i == 0) ? 32'hFFFFFFFF : reg1_i / reg2_i;
                        `EXE_REM:    wdata_o <= (reg2_i == 0) ? reg1_i : $signed(reg1_i) % $signed(reg2_i);
                        `EXE_REMU:   wdata_o <= (reg2_i == 0) ? reg1_i : reg1_i % reg2_i;
                        default:     wdata_o <= `ZeroWord;
                    endcase
                    wd_o <= rd;
                end else begin
                    case(funct3)
                        `EXE_ADD_SUB: begin
                            if (inst_i[30] == 1'b0) begin
                                wdata_o <= op1_add_op2;
                                wd_o    <= rd;
                            end else begin
                                wdata_o <= op1_subtract_op2;
                                wd_o    <= rd;
                            end
                        end
                        `EXE_OR: begin
                            wdata_o <= reg1_i | reg2_i;
                            wd_o    <= rd;
                        end
                        `EXE_AND: begin
                            wdata_o <= reg1_i & reg2_i;
                            wd_o    <= rd;
                        end
                        `EXE_XOR: begin
                            wdata_o <= reg1_i ^ reg2_i;
                            wd_o    <= rd;
                        end
                        `EXE_SLT: begin
                            //注意这里是对大于等于取反了，也就是小于。然后进行符号扩展。
                            //SLTIU SLT SLTU与此相同
                            wdata_o <= {32{(~op1_greater_than_op2_singned)}} & 32'h1;
                            wd_o    <= rd;
                        end
                        `EXE_SLTU: begin
                            wdata_o <= {32{(~op1_greater_than_op2_unsigned)}} & 32'h1;
                            wd_o    <= rd;
                        end
                        `EXE_SLL: begin
                            wdata_o <= reg1_i << reg2_i[4:0];
                            wd_o    <= rd;
                        end
                        // ===== SRL / SRA (funct3=3'b101) =====
                        3'b101: begin
                            if (funct7[5] == 1'b0) begin
                                wdata_o <= reg1_i >> reg2_i[4:0];           // SRL 逻辑右移
                            end else begin
                                wdata_o <= $signed(reg1_i) >>> reg2_i[4:0]; // SRA 算术右移
                            end
                            wd_o    <= rd;
                        end
                        default: begin
                            wdata_o <= `ZeroWord;
                            wd_o    <= `NOPRegAddr;
                        end
                    endcase
                end
            end
            `INST_TYPE_L: begin
                //load指令，从内存地址rs1+imm中读取数据，写入rd
                mem_addr_o <= op1_add_op2;
                is_load_o <= 1'b1;
            end
            `INST_TYPE_S: begin
                //store类指令，将rs2的值写入到imm+rs1的地址处
                mem_addr_o <= reg1_i + {inst_i[31:25], inst_i[11:7]};
                mem_data_o <= reg2_i;
            end
            `EXE_JAL: begin
                wdata_o <= reg2_i;  //reg2_i里放的是pc+4
                wd_o    <= rd;
            end
            `EXE_JALR: begin
                wdata_o <= reg2_i;  //reg2_i里放的是pc+4
                wd_o    <= rd;
            end
            // ===== LUI 指令 =====
            `EXE_LUI: begin
                wdata_o <= {inst_i[31:12], 12'b0};  // 立即数左移12位
                wd_o    <= rd;
            end
            // ===== AUIPC 指令 =====
            `EXE_AUIPC: begin
                wdata_o <= reg1_i;  // ID阶段已计算好 imm + pc 放在 reg1_i
                wd_o    <= rd;
            end
        endcase
    end
    
endmodule