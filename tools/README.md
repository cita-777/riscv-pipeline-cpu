# RISC-V 汇编编译工具

将 RISC-V 汇编代码编译为 Verilog 可读取的十六进制格式。

## 环境要求

```bash
# WSL/Ubuntu
sudo apt update && sudo apt install gcc-riscv64-unknown-elf
```

## 使用方法

```bash
make                  # 编译 fibonacci.s → inst_rom.data
make SRC=xxx.s        # 编译指定汇编文件
make install          # 复制到 Verilog 项目目录
make dump             # 反汇编查看机器码
make clean            # 清理生成文件
```

## 文件说明

| 文件 | 说明 |
|------|------|
| `fibonacci.s` | 斐波那契数列示例程序 |
| `ram.ld` | 链接脚本，定义内存布局 |
| `Makefile` | 自动化编译脚本 |

## 输出格式

生成的 `inst_rom.data` 为小端序十六进制格式，可直接用于 Verilog 的 `$readmemh` 加载。
