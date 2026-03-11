; Assembly control flow statements:
; 
; We can see from the assembly example that there is something going on behind the
; scenes that is relating the cmp instruction to the je instruction it proceeds. This is an
; example of where the CPU’s special flags register is used to capture the outcome of
; the cmp instruction, so that a subsequent conditional jump instruction can determine
; whether or not to jump to the specified address.
; The following jump instructions are available,
; based on an earlier cmp x, y instruction:
; 
; je target  ; jump if equal                 ( i.e. x == y)
; jne target ; jump if not equal             ( i.e. x != y)
; jl target  ; jump if less than             ( i.e. x < y)
; jle target ; jump if less than or equal    ( i.e. x <= y)
; jg target  ; jump if greater than          ( i.e. x > y)
; jge target ; jump if greater than or equal ( i.e. x >= y)
; 
; 
; mov bx, 30
; if (bx <= 4) {
    ; mov al, ’A’
; } else if (bx < 40) {
    ; mov al, ’B’
; } else {
    ; mov al, ’C’
; }
; 
; mov ah, 0x0e ; int=10/ah=0x0e-> BIOS tele-type output
; int 0x10     ; print the character in al
; jmp $        ; Padding and magic number.
; 
; times 510-($-$$) db 0
; dw 0xaa55


mov bx, 30

cmp bx, 4
jle less_eq_4

cmp bx, 40
jl less_40

mov al, 'C'
jmp finally

less_eq_4:
    mov al, 'A'
    jmp finally

less_40:
    mov al, 'B'
    jmp finally

finally:
    mov ah, 0x0e ; int=10/ah=0x0e-> BIOS tele-type output
    int 0x10     ; print the character in al
    jmp $        ; Padding and magic number.

times 510-($-$$) db 0
dw 0xaa55






