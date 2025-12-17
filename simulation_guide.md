# RISC-V CPU 仿真指南

本指南将指导您如何使用 Xilinx Vivado 进行仿真测试。

## 1. 准备工作
- 确认已安装 Xilinx Vivado (推荐 2018.3 版本)。
- 确认 `openriscv.xpr` 项目已打开。
- **已修复路径**：我们刚刚修正了 `inst_rom.v` 中的指令文件路径，现在仿真器应该能正确读取指令。

## 2. 运行仿真
1. 在 Vivado 左侧导航栏 (Flow Navigator) 中，展开 **Simulation**。
2. 点击 **Run Simulation**。
3. 选择 **Run Behavioral Simulation** (由于我们尚未综合，这是最快的验证方式)。

## 3. 观察波形
仿真启动后，Vivado 会自动打开波形窗口。
- **顶层模块**：`openriscv_min_sopc_tb`
- **关键信号**：
    - `CLOCK_50`: 50MHz 时钟
    - `rst`: 复位信号 (高电平复位)
- **观察内部状态**：
    - 您可以将被测模块 `openriscv_min_sopc0` -> `openriscv0` 内部的信号拖入波形视图。
    - 重点关注 `pc` (程序计数器) 和 `inst` (当前指令)。
    - 如果 `inst` 变动且不是 `xxxxxxxx`，说明指令读取成功。

## 4. 常见问题
- **指令为 xx**：
    - 检查 `inst_rom.txt` 文件内容是否符合 hex 格式。
    - 检查 `inst_rom.v` 中的路径是否与实际文件位置一致 (已自动修复，但若您移动了项目，需再次更新)。
