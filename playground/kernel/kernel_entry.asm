[bits 32]
[extern main]   ; declare the external symbol main -> linker must know it
    call main   ; invoke main() in C kernel
    jmp $       ; hang forever when ew return from the kernel

