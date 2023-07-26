; nasmfunc.asm
bits 32
global io_hlt
global write_mem8

section .text
io_hlt:
    hlt
    ret

write_mem8:
    mov ecx,[esp+4]
    mov al,[esp+8]
    mov [ecx],al
    ret
