# Writing a Simple OS from Scratch — Study Notes
> Following [Nick Blundell's *Writing a Simple Operating System from Scratch* (2010)](https://github.com/tpn/pdfs/blob/master/Writing%20a%20Simple%20Operating%20System%20from%20Scratch%20-%20Nick%20Blundell%20-%20Dec%202010.pdf)  
> Companion simulator: [v86 — x86 emulator in the browser](https://copy.sh/v86/)
> WSL: sudo apt install qemu-system-x86

## 16-bit Real Mode

### Reading the Disk

The BIOS loads our bootloader from the **first 512-byte sector** of the disk. But an operating system is much larger than 512 bytes — so the OS must bootstrap the rest of its code from disk into memory manually.

### Segmentation & Absolute Addressing

The CPU runs in **16-bit real mode** initially, giving a maximum addressable range of `0xFFFF` — only **64 KB**.  
To reach more memory, the CPU uses **segment registers**:

| Register | Purpose |
|---|---|
| `cs` | Code segment |
| `ds` | Data segment |
| `ss` | Stack segment |
| `es` | Extra data segment |

**Physical address calculation:**

```
physical_address = 16 × segment_register + offset
```

> **Example:** If `ds = 0x4D` and we execute `mov ax, [0x20]`:
> ```
> physical address = 16 × 0x4D + 0x20
>                  = 0x4D0   + 0x20
>                  = 0x4F0
> ```
> The CPU reads from `0x4F0` even though we wrote `0x20`.

> ⚠️ **Key gotcha:** Segments overlap almost entirely, offset by only **16 bytes** from each other. Different segment:offset pairs can point to the **same physical location**.

---

### Hard Disks & CHS Addressing

Mechanical hard drives store data using physical coordinates — **Cylinder-Head-Sector (CHS)**:

| Coordinate | Meaning |
|---|---|
| **Cylinder** | Discrete distance of the read/write head from the outer edge of the platter |
| **Head** | Which platter surface (top/bottom, which disk) |
| **Sector** | A 512-byte arc-shaped region on a circular track, referenced by index |

The metallic coating on platters can be magnetized and demagnetized to represent bits — hence the physical coordinates matter for retrieval.

---

### BIOS Disk Interrupt `0x13`

The BIOS provides **interrupt `0x13`** to abstract away disk bus details (USB, SATA, etc.) and read sectors via CHS addressing.

**Register setup before calling `int 0x13`:**

| Register | Value | Meaning |
|---|---|---|
| `ah` | `0x02` | BIOS read sector function |
| `dl` | drive number | `0` = first drive |
| `ch` | cylinder | which cylinder |
| `dh` | head | which platter side |
| `cl` | sector | which sector (1-indexed) |
| `al` | count | number of sectors to read |
| `es:bx` | destination address | where to store data in memory |

```asm
mov ah, 0x02        ; BIOS read sector function
mov dl, 0           ; drive 0
mov ch, 3           ; cylinder 3
mov dh, 1           ; 2nd side of floppy
mov cl, 4           ; 4th sector of the track
mov al, 5           ; read 5 sectors

mov bx, 0xa000
mov es, bx
mov bx, 0x1234      ; data will be read to 0xa000:0x1234

int 0x13            ; issue the interrupt
```

**Error checking — BIOS flags after `int 0x13`:**

| Flag | Meaning |
|---|---|
| `CF` (Carry Flag) | Set if a general fault occurred — check with `jc` |
| `al` | Set to the actual number of sectors read — compare against requested |

```asm
int 0x13
jc disk_error                   ; jump if carry flag set

cmp al, <sectors_requested>
jne disk_error                  ; jump if count doesn't match

disk_error:
    mov bx, DISK_ERROR_MSG
    call print_string
    jmp $                       ; halt
```

---

## From 16-bit Real Mode to 32-bit Protected Mode

### What Changes in 32-bit Mode

| Feature | 16-bit Real Mode | 32-bit Protected Mode |
|---|---|---|
| Register width | 16-bit (`ax`, `bx` …) | 32-bit (`eax`, `ebx` …) |
| General purpose registers | `ax`–`dx`, `si`, `di` | + `fs`, `gs` |
| Addressable memory | 64 KB | 4 GB |
| Memory protection | None | Segments can have privilege levels |
| Virtual memory | No | Yes |
| BIOS routines | Available | **Unavailable** — OS must provide its own drivers |

---

### Global Descriptor Table (GDT)

In protected mode, segment registers no longer hold a raw value to multiply. Instead they hold an **index** into the **GDT**, which describes each memory segment in detail.

**Segment Descriptor (SD) — 8-byte structure:**

| Field | Size | Description |
|---|---|---|
| Base address | 32 bits | Where the segment starts in physical memory |
| Segment limit | 20 bits | Size of the segment |
| Flags | variable | Privilege level, read/write/execute permissions, etc. |

**GDT Descriptor** — a small structure that tells the CPU where the GDT is:

| Field | Size |
|---|---|
| GDT size | 16 bits |
| GDT address | 32 bits |

For the **Intel flat model** (the simplest setup), we define two overlapping segments that span the full 4 GB — one for code, one for data.

---

### Making the Switch

Steps to transition from 16-bit real mode to 32-bit protected mode:

1. **`cli`** — Disable interrupts. The BIOS interrupt vector table (IVT) is meaningless in protected mode.
2. **`lgdt`** — Point the CPU to our GDT descriptor.
3. **Set bit 0 of `cr0`** — Update the control register using OR to avoid clobbering existing bits:
   ```asm
   mov eax, cr0
   or  eax, 0x1
   mov cr0, eax
   ```
4. **Far jump** — Flush the CPU pipeline. Due to pipelining, the CPU may have already fetched instructions in the old mode. A far jump forces it to discard those and start fresh in 32-bit mode:
   ```asm
   jmp <segment_selector>:<offset>
   ```

---

## Understanding C Compilation

### Object Files

```bash
gcc -ffreestanding -c kernel/basic.c -o kernel/basic.o
objdump -d kernel/basic.o
```

```asm
0000000000000000 <my_function>:
   0:   55                    push   %rbp
   1:   48 89 e5              mov    %rsp,%rbp
   4:   b8 ba ba 00 00        mov    $0xbaba,%eax
   9:   5d                    pop    %rbp
   a:   c3                    ret
   b:   90                    nop    ×5
```

Object files are **annotated machine code** — they retain symbolic labels and use **relative** internal addresses rather than absolute ones.

When multiple `.o` files are **linked** together, the linker resolves all relative references into absolute addresses within the final binary:

```
call <function_x>   →   call 0x12345
```

---

### Compiler Behavior — Stack & Variables

**Prologue — setting up the stack frame:**
```asm
55          push ebp            ; save caller's base pointer
89 E5       mov  ebp, esp       ; anchor our frame base
83 EC 10    sub  esp, 0x10      ; allocate 16 bytes for locals
```

> **Why 16 bytes for a 4-byte `int`?**  
> This is **stack alignment**. The x86 ABI requires the stack to stay 16-byte aligned. At the cost of a few wasted bytes, the CPU can access data faster when it is aligned to its natural boundary.

**Storing a local variable:**
```asm
C7 45 FC BA BA 00 00    mov dword [ebp-0x4], 0xbaba
```

The compiler places `int x` at offset `-4` from `ebp`. The `dword` qualifier means a 32-bit write — matching the size of `int`.

```
Stack layout:
┌──────────────┐ ← ebp
│  saved ebp   │
├──────────────┤
│  0x0000baba  │ ← ebp-0x4  (our int)
├──────────────┤
│   padding    │ ← alignment bytes
└──────────────┘ ← esp
```

**Return value:**
```asm
8B 45 FC    mov eax, [ebp-0x4]
```

In the **cdecl calling convention**, integer return values are passed back to the caller in `eax`. The caller always knows to look there.

**Epilogue — tearing down the frame:**
```asm
C9          leave       ; shorthand for: mov esp,ebp / pop ebp
C3          ret         ; pop return address from stack into EIP
```

---

### Accessing Specific Memory Addresses with Pointers

In normal C, the compiler decides where variables live in memory. But writing OS drivers requires reading and writing **specific, known hardware addresses** — for example, the VGA text buffer at `0xB8000`.

**C pointers** let us do exactly this:

```c
char *video_address = (char*) 0xb8000;
*video_address = 'X';   // write 'X' to VGA text buffer
```

At the assembly level, a pointer is just a **4-byte integer stored on the stack** whose value happens to be a memory address:

```asm
C7 45 FC 00 80 0B 00    mov dword [ebp-0x4], 0xb8000
```

> All pointers — regardless of what they point to — are the same size (4 bytes on 32-bit). The type (`char*`, `int*`, etc.) only tells the **compiler** how many bytes to read or write when dereferencing. The CPU sees only the address.


## Writing, building and loading your kernel
Recipe summary:
1. write and compile the kernel code
1. write and assemble the boot sector code
1. create kernel image that includes: boot sector and compiled kernel
1. load our kernel code into memory
1. switch to 32-bit protected mode
1. execute our kernel

### Writing our Kernel
From now on I'm using WSL (some extra flags are added to compile things to 32 bits from my 64 bits machine).
```
    gcc --freestanding -m32 -fno-pic -c kernel.c -o kernel.o
    ld -m elf_i386 -o kernel.bin -Ttext 0x1000 --oformat binary kernel.o
```
The origin of our code, once loaded into memory, will be 0x1000. Thus local
address references will be offseted from this origin.

### Creating a boot sector to BOOTSTRAP our kernel
* bootstrap: load and begin executing
BIOS will load only the boot sector of our disk (512 bytes). We know that from
BIOS we can use some routines to load extra data from the disk but as soon as we
change to protected 32 bit mode we'd have to create our own disk drivers to do so!
* **Kernel Image**: To avoid this issue kernel images gather both the boot sector
 and the operating system kernel. This can vbe written to the initial sectors of
 the boot disk such that the boot sector always points at the head of the kernel
 image

recall: nasm boot_sect.asm -f bin -o boot_sect.bin

> `cat boot_sect.bin kernel.bin > os-image`

qemu-system-i386 -fda os-image

### Finding our way into the kernel
currently the kernel is being loaded exactly at the memory address we specify and we call (jump and execute) this memory address
when we have switch to 32-bit protected mode, but ... compiler could have altered the generated machine code oder, meaning that
the `main`entry point could not be there or worst the entry point could be erronously pointing within an auxuliary function
and return before ever reaching main...

to be completely specific we have a problem with the absolute memory address the `main` function is going to have in this
os-image binary. Hmm but didn't linker solve this? Exactly, linker takes object files and join them together thanks to the expressivity of
the object file format that will keep the function name label on its information being able to resolve this "relative" label naming into
an absolute memory address. Cool, let's create a kernel_entry.asm assemble it into an object (ELF executable and linking format option)
linking together to the kernel.o object.

`nasm kernel_entry.asm -f elf -o kernel_entry.o`
`ld -m elf_i386 -o kernel.bin -Ttext 0x1000 --oformat binary kernel_entry.o kernel.o`
this stays the same:
`cat boot_sect.bin kernel.bin > os-image`

### Using Makefile
Dude, we have an awful amount of building commands...
```
    gcc --freestanding -m32 -fno-pic -c kernel.c -o kernel.o
    nasm kernel_entry.asm -f elf -o kernel_entry.o
    ld -m elf_i386 -o kernel.bin -Ttext 0x1000 --oformat binary kernel_entry.o kernel.o
    nasm boot_sect.asm -f bin -o boot_sect.bin
    cat boot_sect.bin kernel.bin > os-image
    qemu-system-i386 -fda os-image
```
Special Makefile variables:
- $^ is substituted with all of the target's dependency files
- $< is the first dependency
- $@ target file

if make is run without target then the first target in the Makefile is run as
the default -> usually you add a phoney target as `all:` to control this default behavior

