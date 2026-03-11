; at the CPU level a function is nothing else but a jump to particular set of useful
; instructions that are executed and a jump back to where the initial jump was made.

mov al, 'H'   ; store in al register

; naive approach:
; jmp my_print_function
; return_to_here:  ; line-line so we can get back

call my_print_function


my_print_function:
    mov ah, 0x0e
    int 0x10 ; print the character in al register -> this function knows where to look!
             ; because i hardcoded it but in higher level languages the caller and the calee must have
             ; some agreement on where and how many parameters will be passed
             ; only drawback we cannot really use this print function from anywhere in the code
             ; as the return flag is not dynamic  -> the caller should store the correct return address
             ; if this is made in a known address the called code could read it and come back to it
             ; REGISTER IP --> instruction pointer --> this is not accessible by us, the CPU provides
             ; instruction ret and call for us to use it.
             ; call: jumps to function and push the address to the stack
             ; ret: pops the address off the stacks and jumps back to it.
    ; naive approach
    ; jmp return_to_here
    ret      ; address automatically popped from the stack


; problem: when we call a function internally to perform its job it might modify several of the registers we might
; be using for other things -> registers are scarsed so it might certainly do...
; idea: the function could push the registers it is going to use to the stack and then pop them off restoring the
; originals before returning, CPU offers pusha and popa -> push and pop all registers to and from the stack 

some_function:
    pusha       ; push all registers to the stack

    mov bx, 10
    add bx, 20
    mov ah, 0x0e
    int 0x10

    popa       ; restore all the original values
    ret

; extra: %include "myfile.asm" is a clause provided by nasm that will just replace this by the file contents
