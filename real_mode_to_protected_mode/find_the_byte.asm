;
; Simple Boot Sector program demonstrating addressing.
; Screen results:
; Booting from Floppy...                                                          
; H-H▌HXHè
;  ^

mov ah, 0x0e      ; scrolling teletype bios routine

mov al, 'H'
int 0x10

mov al, the_secret
int 0x10

mov al, 'H'
int 0x10

mov al, [the_secret]
int 0x10

mov al, 'H'
int 0x10

mov bx, the_secret
add bx, 0x7c00
mov al, [bx]
int 0x10

mov al, 'H'
int 0x10

mov al, [0x7c1e]
int 0x10

jmp $

the_secret:
    db "X"          ; "X" is 0x1e

times 510-($-$$) db 0
dw 0xaa55

