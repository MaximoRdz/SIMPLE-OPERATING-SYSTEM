#include <stdio.h>
#include <stdint.h>


int main()
{
    int16_t i = 1;             // 0x0001 -> 16 bits <=> 2 bytes
                               // x86 architecture 0x00 0x01
    int8_t *p = (int8_t *) &i; // read first byte from memory

    if (p[0] == 1) printf("The system is little endian.\n");
    else printf("The system is big endian.\n");

    return 0;
}

