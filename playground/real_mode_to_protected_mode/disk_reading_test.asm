[org 0x7c00]

    mov [BOOT_DRIVE], dl
    
    mov bp, 0x8000 ; set stack safely out of the way
    mov sp, bp

    mov bx, 0x9000 ; load 5 sectors 0x0000(ES):0x9000(BX)
    mov dh, 5

    mov dl, [BOOT_DRIVE]
    call disk_load

    mov dx, [0x9000] ; print the first loaded word
    call print_hex   ; -> 0xdada
    call print_newline

    mov dx, [0x9000] ; print the first loaded word from the second loaded sector
    call print_hex   ; -> 0xface
    call print_newline
    
    jmp $

%include "disk_load.asm"
%include "print_function.asm"

BOOT_DRIVE: db 0

times 510-($-$$) db 0
dw 0xaa55

; the BIOS loads only the first 512bytes so we add more sectors to validate the disk reading function
times 256 dw 0xdada
times 256 dw 0xface

