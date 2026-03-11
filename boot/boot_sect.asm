; BOOT SECTOR: Boots a C kernel in 32-bit protected mode

[org 0x7c00]
KERNEL_OFFSET equ 0x1000       ; where to load our kernel code
                               ; it should match the memory offset of code compilation

    mov [BOOT_DRIVE], dl       ; boot drive is stored in DL
    mov bp, 0x9000             ; set-up stack
    mov sp, bp

    mov bx, MSG_REAL_MODE
    call print_string          ; still from 16-bit real mode
    call print_newline

    call load_kernel

    call switch_to_pm          ; switch to protected mode from which we wil not return

    jmp $

%include "print_function.asm"
%include "disk_load.asm"
%include "gdt_32_pm.asm"
%include "protected_mode.asm"
%include "print_function_pm.asm"

[bits 16]

load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print_string
    call print_newline

    mov bx, KERNEL_OFFSET      ; disk load function parameters set-up
    mov dh, 15                 ; 15 sectors will be loaded excluding the boot disk
    mov dl, [BOOT_DRIVE]
    call disk_load

    ret

[bits 32]
; returning point after switching and initializing protected mode
BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm

    call KERNEL_OFFSET         ; jump to the address of the kernel code

    jmp $

BOOT_DRIVE       db 0
MSG_REAL_MODE    db "Started in 16-bit Real Mode", 0
MSG_PROT_MODE    db "Successfully landed in 32-bit Protected Mode", 0
MSG_LOAD_KERNEL  db "Loading Kernel into memory.", 0

times 510-($-$$) db 0
dw 0xaa55

