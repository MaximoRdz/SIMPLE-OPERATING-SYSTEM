print_string:
    ; bx is the parameter of this function
    pusha

    mov ah, 0x0e   ; int=10/ah=0x0e -> BIOS tele-type output

.loop:
    mov al, [bx]   ; load character
    cmp al, 0
    je .done

    int 0x10       ; pritn the character in al

    inc bx
    jmp .loop

.done:
    popa
    ret


print_newline:
    pusha
    mov ah, 0x0e
    mov al, 0x0d   ; carriage return -> cursor to 0
    int 0x10
    mov al, 0x0a   ; paper one line down (line feed)
    int 0x10
    popa
    ret

;
; PRINT HEX
;
; 16 bits = 4 hex digits
; 1010 1111 0001 0010
; A    F    1    2
print_hex:
    pusha

    mov bx, HEX_OUT + 2   ; skip 0x
    mov cx, 4

.hex_loop:
    rol dx, 4             ; bring next nibble to low bits
    mov al, dl
    and al, 0x0f

    cmp al, 9
    jle .digit

    add al, 7      ; in ASCII '9'=57 'A'=65 gap of 8

.digit:
    add al, "0"    ; 
    mov [bx], al

    inc bx
    loop .hex_loop

    mov bx, HEX_OUT

    call print_string

    popa
    ret

HEX_OUT:
    db "0x0000", 0
