# ============================================================
# RISC-V 汇编编译 Makefile
# 用法：
#   make              - 编译默认源文件 (fibonacci.s)
#   make SRC=xxx.s    - 编译指定源文件
#   make clean        - 清理生成的文件
#   make verilog      - 使用 objcopy 生成 Verilog 格式
# ============================================================

# 工具链配置 (使用 apt 安装的 riscv64 工具链)
CROSS_COMPILE = riscv64-unknown-elf-
CC      = $(CROSS_COMPILE)gcc
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

# 架构配置 (32位 RISC-V)
ARCH    = -march=rv32i -mabi=ilp32

# 源文件 (默认为 fibonacci.s，可通过 make SRC=xxx.s 覆盖)
SRC     ?= fibonacci.s

# 链接脚本
LDSCRIPT = ram.ld

# 输出文件名
TARGET  = inst_rom

# 目标 Verilog 测试文件目录
VERILOG_DIR = ../openriscv/openriscv.srcs/sources_1/imports/code

# ============================================================
# 默认目标：只生成 .data，自动清理中间文件
# ============================================================
.PHONY: all clean verilog dump help

all: $(TARGET).data
	@rm -f $(TARGET).om $(TARGET).bin
	@echo "✓ 生成完成: $(TARGET).data"

# ============================================================
# 生成 .data 文件（十六进制格式，供 Verilog $readmemh 使用）
# 注意：使用小端序格式（字节反转），匹配 Verilog ROM 期望的格式
# ============================================================
$(TARGET).data: $(TARGET).bin
	@echo "[4/4] 生成十六进制文件（小端序）..."
	hexdump -v -e '4/1 "%02x" "\n"' $< > $@

# ============================================================
# 生成 .bin 文件（纯二进制）
# ============================================================
$(TARGET).bin: $(TARGET).om
	@echo "[3/4] 提取二进制..."
	$(OBJCOPY) -O binary $< $@

# ============================================================
# 生成 .om 文件（ELF 格式）
# ============================================================
$(TARGET).om: $(SRC) $(LDSCRIPT)
	@echo "[1/4] 汇编源文件: $(SRC)"
	@echo "[2/4] 链接生成 ELF..."
	$(CC) $(ARCH) -nostdlib -T $(LDSCRIPT) $(SRC) -o $@

# ============================================================
# 使用 objcopy 的 Verilog 格式（备选方案）
# ============================================================
verilog: $(TARGET).om
	@echo "生成 Verilog 十六进制格式..."
	$(OBJCOPY) -O verilog $< $(TARGET).verilog.data
	@echo "生成完成: $(TARGET).verilog.data"

# ============================================================
# 反汇编（调试用）
# ============================================================
dump: $(TARGET).om
	$(OBJDUMP) -d $<

# ============================================================
# 安装到 Verilog 项目目录
# ============================================================
install: $(TARGET).data
	@echo "复制 $(TARGET).data 到 Verilog 项目..."
	cp $(TARGET).data $(VERILOG_DIR)/inst_rom.txt
	@echo "安装完成！"

# ============================================================
# 清理
# ============================================================
clean:
	@echo "清理生成的文件..."
	rm -f *.o *.om *.bin *.data *.verilog.data

# ============================================================
# 帮助信息
# ============================================================
help:
	@echo "RISC-V 汇编编译工具"
	@echo ""
	@echo "用法："
	@echo "  make              - 编译 fibonacci.s"
	@echo "  make SRC=xxx.s    - 编译指定的汇编文件"
	@echo "  make dump         - 反汇编查看机器码"
	@echo "  make verilog      - 使用 objcopy 生成 Verilog 格式"
	@echo "  make install      - 复制 .data 到 Verilog 项目目录"
	@echo "  make clean        - 清理所有生成的文件"
	@echo "  make help         - 显示此帮助信息"
