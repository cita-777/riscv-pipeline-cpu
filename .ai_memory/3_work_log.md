# 开发日志

## 2025-12-24
- 完成 18 条新指令实现，指令总数达到 50 条
- RV32I 补全：LUI, AUIPC, SRAI, SRL, SRA
- RV32M 扩展：MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU
- 杂项指令：FENCE, FENCE.I, ECALL, EBREAK, CSRRW
- 修改文件：define.v (+22行), id.v (+30行), ex.v (+45行)

## 2025-12-05
- 完成项目结构分析
- 识别出 19 个 Verilog 源码模块
- 梳理五级流水线架构：IF → ID → EX → MEM → WB
- 记录支持的 RV32I 指令子集
- 初始化记忆库文件
