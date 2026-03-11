/*C wrappers of low level Assembly interrupts instructions.
 *
 * */

unsigned char port_byte_in(unsigned short port)
{
    // Read byte from the specified port
    // "=a" (result) -> AL register to var RESULT
    // "d" (port) -> load EDX with port
    unsigned char result;
    __asm__("in %%dx, %%al" : "=a" (result) : "d" (port));
    return result;
}

void port_byte_out(unsigned short port, unsigned char data)
{
    // "=a" (data) -> load EAX with data
    // "d" (port) -> load EDX with port
    __asm__("out %%al, %%dx" : : "a" (data), "d" (port));
}

unsigned short port_word_in(unsigned short port)
{
    // Read word from the specified port
    // "=a" (result) -> AX register to var RESULT
    // "d" (port) -> load EDX with port
    unsigned char result;
    __asm__("in %%dx, %%ax" : "=a" (result) : "d" (port));
    return result;
}

void port_word_out(unsigned short port, unsigned short data)
{
    // "=a" (data) -> load EAX with data
    // "d" (port) -> load EDX with port
    __asm__("out %%ax, %%dx" : : "a" (data), "d" (port));
}

