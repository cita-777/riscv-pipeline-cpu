# 项目记忆

## 项目目标
基于 Verilog HDL 实现一个五级流水线 RISC-V CPU，用于合肥工业大学宣城校区《系统硬件综合设计》课程设计。该 CPU 可在 Xilinx FPGA 上仿真运行。

## 技术架构
- **语言**：Verilog HDL
- **开发工具**：Xilinx Vivado 2018.3
- **目标平台**：FPGA 开发板（仅支持仿真，无法烧板）
- **指令集**：RV32I 子集

## 项目结构
```
riscv-pipeline-cpu/
├── README.md                    # 项目说明
├── cpu_tutorial.md              # CPU 原理教程
├── simulation_guide.md          # 仿真指南
├── openriscv/                   # Vivado 工程目录
│   ├── openriscv.xpr            # Vivado 项目文件
│   └── openriscv.srcs/
│       └── sources_1/imports/
│           ├── code/            # CPU 核心代码（17个文件）
│           └── 7-seg/           # 数码管驱动（2个文件）
└── 自述/                        # 答辩自述文档
```

## 五级流水线架构
```
取指 (IF) → 译码 (ID) → 执行 (EX) → 访存 (MEM) → 写回 (WB)
  ↓           ↓           ↓            ↓           ↓
pc_reg.v   id.v        ex.v        mem.v      regfile.v
inst_rom.v  regfile.v
  ↓           ↓           ↓            ↓
if_id.v    id_ex.v     ex_mem.v    mem_wb.v   (流水线寄存器)
```

## 核心模块列表
| 模块 | 文件 | 功能 |
|------|------|------|
| 程序计数器 | `pc_reg.v` | 指令地址生成 |
| 指令存储器 | `inst_rom.v` | 存储程序指令 |
| IF/ID 寄存器 | `if_id.v` | 取指-译码流水线寄存器 |
| 译码模块 | `id.v` | 指令解析、寄存器读取 |
| 寄存器堆 | `regfile.v` | 32 个通用寄存器 |
| ID/EX 寄存器 | `id_ex.v` | 译码-执行流水线寄存器 |
| 执行模块 | `ex.v` | ALU 运算 |
| EX/MEM 寄存器 | `ex_mem.v` | 执行-访存流水线寄存器 |
| 访存模块 | `mem.v` | 数据内存访问 |
| 数据存储器 | `data_ram.v` | 数据存储 |
| MEM/WB 寄存器 | `mem_wb.v` | 访存-写回流水线寄存器 |
| 控制模块 | `ctrl.v` | 流水线暂停控制 |
| 顶层模块 | `openriscv.v` | 连接所有子模块 |

## 支持的指令 (共50条)
- **I 型**：addi, ori, xori, andi, slli, srli, srai, slti, sltiu
- **R 型**：add, sub, or, xor, and, sll, srl, sra, slt, sltu
- **B 型**：beq, bne, blt, bge, bltu, bgeu
- **L 型**：lw, lb, lbu, lh, lhu
- **S 型**：sw, sb, sh
- **跳转**：jal, jalr
- **U 型**：lui, auipc
- **M 扩展**：mul, mulh, mulhsu, mulhu, div, divu, rem, remu
 
说明：本工程当前实现与测试程序不包含 fence/fence.i/ecall/ebreak/csrrw 等杂项/CSR 指令。

## 核心规范
- 采用数据前推和流水线暂停解决数据冲突
- 分支指令在译码阶段计算跳转地址
- 测试程序为指令覆盖测试，位于 `openriscv/openriscv.srcs/sources_1/imports/code/inst_rom.txt`

## 参考资料
- 雷思磊《自己动手写CPU》- OpenMIPS
- tinyriscv: https://github.com/liangkangnan/tinyriscv
