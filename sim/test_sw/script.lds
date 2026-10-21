ENTRY(_start)
SECTIONS
{
    . = 0x0000;
    .text : {*(.text)}
}