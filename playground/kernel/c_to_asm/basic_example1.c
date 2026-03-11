int callee_function(int arg)
{
    int my_arg = arg + 1;
    return my_arg;
}

void caller_function()
{
    int ret_arg = callee_function(0xdede);
}
// 0000000F  8B45FC            mov eax,[ebp-0x4]      => load local variable into eax (return value)
// 00000012  C9                leave                  => tear down stack frame
// 00000013  C3                ret                    => return to caller
// 00000014  55                push ebp               => save caller's ebp
// 00000015  89E5              mov ebp,esp            => set our frame base
// 00000017  83EC14            sub esp,byte +0x14     => allocate 20 bytes on stack
//                                                    => why 20 bytes?
//                                                    => 4 local var at [ebp-0x4]
//                                                    => 4 padding
//                                                    => 4 argument slot at [esp] for the upcoming call
//                                                    => 8 extra alignment padding (16-byte ABI alignment rule)
// 0000001A  C70424DEDE0000    mov dword [esp],0xdede => argument located directly into [esp]
//
//                                                    => Stack at this moment:
//                                                    => ┌──────────────┐ ← ebp
//                                                    => │  saved ebp   │
//                                                    => ├──────────────┤
//                                                    => │  [ebp-0x4]   │ ← local var (empty for now)
//                                                    => ├──────────────┤
//                                                    => │   padding    │
//                                                    => ├──────────────┤
//                                                    => │   0x0000dede │ ← [esp]  ← function argument ready here
//                                                    => └──────────────┘ ← esp
// 00000021  E8DAFFFFFF        call 0x0               => call the very start of the program i.e. callee_function
// 00000026  8945FC            mov [ebp-0x4],eax      => take whatever callee function returned and storeit in the stack
// 00000029  90                nop
// 0000002A  C9                leave
// 0000002B  C3                ret
