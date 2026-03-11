C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)

OBJ = ${C_SOURCES:.c=.o}

all: os-image

run: all
	qemu-system-i386 -fda os-image

os-image: boot/boot_sect.bin kernel.bin
	cat $^ > os-image

# Build kernel binary:
# 	- kernel_entry -> jump to main()
# 	- compiled c kernel objects
kernel.bin: kernel/kernel_entry.o ${OBJ}
	ld -m elf_i386 -o $@ -Ttext 0x1000 --oformat binary $^

# Compile C code generic rule (linked to all headers for simplicity)
%.o : %.c ${HEADERS}
	gcc --freestanding -m32 -fno-pic -c $< -o $@

# Assemble the kernel entry
%.o: %.asm
	nasm $< -f elf -o $@

# Build the boot sector bin
# -I can be include to point to "../foo/bar" with required asm files
NASM_INCLUDE_PATH := ./16bit

%.bin: %.asm
	nasm $< -f bin -o $@ -I$(NASM_INCLUDE_PATH)

clean:
	rm -rf *.bin *.dis *.o os-image
	rm -rf kernel/*.o boot/*.bin drivers/*.o
	
