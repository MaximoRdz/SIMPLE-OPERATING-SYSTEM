; printing string in screen in 32 bits  protected mode.
; this routine always print the string to the top left of the screen
; overwritting the previous messages, there is no need to overcomplicate the
; behavior here so it'll stay like that

[bits 32]

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

print_string_pm:
    pusha
    mov edx, VIDEO_MEMORY

print_string_pm_loop:
    mov al, [ebx]  ; char at ebx at all
    mov ah, WHITE_ON_BLACK

    cmp al, 0
    je print_string_pm_done

    mov [edx], ax  ; store char and attrs at current char cell

    add ebx, 1     ; next char in string
    add edx, 2     ; next character cell in cell vid mem

    jmp print_string_pm_loop

print_string_pm_done:
    popa
    ret
