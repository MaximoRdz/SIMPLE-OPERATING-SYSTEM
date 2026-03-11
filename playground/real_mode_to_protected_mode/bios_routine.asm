; Assembly Hello World! From Boot Loader Routine
; BIOS load the boot sector to the address 0x7c00
mov ah, 0x0e

mov al, 'H'
int 0x10
mov al, 'e'
int 0x10
mov al, 'l'
int 0x10
mov al, 'l'
int 0x10
mov al, 'o'
int 0x10

jmp $

times 510-($-$$) db 0
dw 0xaa55

