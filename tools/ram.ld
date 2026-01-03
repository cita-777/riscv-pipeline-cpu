/* RAM 链接脚本 for RISC-V CPU */

OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    /* 指令 ROM 区域，起始地址 0x0，大小 4KB */
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 4K
}

SECTIONS
{
    /* 代码段 */
    .text :
    {
        *(.text.init)
        *(.text)
    } > ROM

    /* 只读数据段 */
    .rodata :
    {
        *(.rodata)
    } > ROM

    /* 数据段 */
    .data :
    {
        *(.data)
    } > ROM
}
