; load DH sectors from disk to ES:BX from drive DL
disk_load:
    push dx

    mov ah, 0x02 ; bios read sector function
    mov al, dh   ; read dh sectors
    mov ch, 0x00 ; cylinder 0
    mov dh, 0x00 ; head 0
    mov cl, 0x02 ; read from second sector

    int 0x13     ; bios interrupt

    jc disk_error

    pop dx
    cmp dh, al   ; if AL (sectors read) != DH sectors req
    jne disk_error
    ret

disk_error:
    mov bx, DISK_ERROR_MSG
    call print_string
    jmp $

DISK_ERROR_MSG db "Disk read error!", 0

