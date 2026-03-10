
param(
[int]$Lines = 10
)

Write-Host "Compiling C file..."
gcc -m32 -ffreestanding -c kernel/basic.c -o kernel/basic.o
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Linking ELF..."
gcc -m32 -nostdlib kernel/basic.o -o kernel/basic.elf
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Converting to raw binary..."
objcopy -O binary kernel/basic.elf kernel/basic.bin
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Disassembling binary..."
ndisasm -b 32 kernel/basic.bin > kernel/basic.dis

Write-Host ""
Write-Host "First $Lines lines of kernel/basic.dis:"
Write-Host "--------------------------------------"

Get-Content kernel/basic.dis -TotalCount $Lines
