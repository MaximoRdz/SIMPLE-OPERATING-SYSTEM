all: os-image

run: all
	qemu-system-i386 -fda os-image

os-image: boot_sect.bin kernel.bin
	cat $^ > os-image

# Build the kernel binary
# $^ : replaces with dependencies
kernel.bin: kernel_entry.o kernel.o
	ld -m elf_i386 -o $@ -Ttext 0x1000 --oformat binary $^

# Build the kernel object file
kernel.o: kernel.c
	gcc --freestanding -m32 -fno-pic -c $< -o $@

# Build the kernel entry object file
kernel_entry.o: kernel_entry.asm
	nasm $< -f elf -o $@

boot_sect.bin: boot_sect.asm
	nasm $< -f bin -o $@

clean:
	rm *.bin *.o

kernel.dis: kernel.bin
	ndisasm -b 32 $< > $@
