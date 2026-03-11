[org 0x7c00]     ; the bios load our code here

    mov bx, HELLO_MSG
    call print_string

    call print_newline

    mov bx, GOODBYE_MSG
    call print_string

    call print_newline

    mov bx, INFO_MSG
    call print_string
        
    mov dx, bx
    call print_hex
    call print_newline

    jmp $

%include "print_function.asm"

HELLO_MSG:
    db "Hello , World!", 0 ; db: literally places that byte right there
                           ; in the executable
GOODBYE_MSG:
    db "Goodbye...", 0

INFO_MSG:
    db "Now printing bx address:    ", 0


    times 510-($-$$) db 0
    dw 0xaa55
