ENTRY(_start)
SECTIONS
{
    . = 0x4000;
    .text : {*(.text)}
}