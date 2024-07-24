SECTIONS
{
    PROVIDE (__executable_start = 0x08048000); . = 0x08048000 + SIZEOF_HEADERS;

    .text 0x10200               :
    {
        *(.text)

    } =0x90909090

    .rodata : { *(.rodata)}

    .rdata : { *(.rdata)}

    . = ALIGN (512);

    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(.bss)
    }

}
