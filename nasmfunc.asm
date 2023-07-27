; nasmfunc.asm
bits 32
global _io_hlt, _io_cli, _io_sti, _io_stihlt
global _io_in8, _io_in16, _io_in32
global _io_out8, _io_out16, _io_out32
global _io_load_eflags, _io_store_eflags

section .text
_io_hlt:
    hlt
    ret

_io_cli:     ; void _io_cli(); Clear interrupt flag
    cli
    ret

_io_sti:     ; void _io_sti(); Set interrupt flag
    sti
    ret

_io_stihlt:  ; void _io_stihlt();
    sti
    hlt
    ret

_io_in8:     ; int _io_in8(int port);
    mov edx, [esp+4]    ; port
    mov eax, 0
    in  al, dx
    ret

_io_in16:     ; int _io_in16(int port);
    mov edx, [esp+4]    ; port
    mov eax, 0
    in  al, dx
    ret

_io_in32:     ; int _io_in32(int port);
    mov edx, [esp+4]    ; port
    in  eax, dx
    ret

_io_out8:     ; int _io_out8(int port, int data);
    mov edx, [esp+4]    ; port
    mov al, [esp+8]     ; data
    out dx, al
    ret

_io_out16:     ; int _io_out16(int port, int data);
    mov edx, [esp+4]    ; port
    mov al, [esp+8]     ; data
    out dx, ax
    ret

_io_out32:     ; int _io_out32(int port, int data);
    mov edx, [esp+4]    ; port
    mov al, [esp+8]     ; data
    out dx, eax
    ret

_io_load_eflags:     ; int _io_load_eflags();
    pushfd          ; push eflags
    pop eax
    ret

_io_store_eflags:    ; void _io_store_eflags(int eflags);
    mov eax, [esp+4]
    push eax
    popfd           ; pop eflags
    ret
