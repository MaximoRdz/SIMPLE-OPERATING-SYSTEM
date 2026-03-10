 ; Using the Stack
 ; The Stack is just a simple solution to the following inconvinience:
 ; the CPU has a limited number of registers for the temporary storage of our
 ; routine's local variables.
 ; of course, we could make use of main memory, but specifying memory addresses
 ; manually is inconvenient (in fact we don't care where in memory we place these
 ; variables).
 ; the stack will also come handy for argument passing to realise function calls.

 ; the CPU offers push and pop allowing us to retrieve and store values from the top
 ; of the stack -> WITHOUT WORRYING EXACTLY WHERE THEY ARE STORED
 ; the stack is implemented via two CPU registers bp sp
 ; - address of stack base
 ; - address of stach top
 ; as the stack expands as we push data onto it, we usually set the satack0s base far away
 ; from important regions of memory
 ;
 ; * the stack grows downwards! from the base pointer, when we issue a push the value gets stored
 ; below and not above, the address of bp and sp is decremented by the value's size.

mov ah, 0x0e

mov bp, 0x8000 ; Set the base of the stack a little above where BIOS
mov sp, bp

push 'A' ; sp 0x7ffe
push 'B' ; sp 0x7ffc
push 'C' ; sp 0x7ffa   stack top is growing towards lower addresses (code grows upward to avoid collisions)

pop bx ; pop to bx
mov al, bl
int 0x10      ; print C
pop bx
mov al, bl
int 0x10         ; print B
mov al, [0x7ffe] ; print A

int 0x10

jmp $ ; jump to address of current instruction

times 510-($-$$) db 0
dw 0xaa55

