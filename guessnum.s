.section .data
start_msg:
    .string "Please input number or 'q' to exit \n"
right_msg:
    .string "\nBingo (xxxx) \n\n"

input:
    .string "                                    "
result:
    .string "           A   B  \n"
answer:
    .string "xxxx"

digitlist:
    .ascii  "xxxxxxxxxx"
not_used:
    .ascii  "x"

acount:
    .byte 0
bcount:
    .byte 0

nowsecond:
    .long 0

.equ EXIT,         'q'

.equ A_COUNT_POS,  10
.equ B_COUNT_POS,  14
.equ RES_ANS_POS,  8
.equ CHARACTER_0,  0x30

//-----------------------------------------------------------------------------
.section .text

.global _start

_start:

reset_game:
    call newanswer1

    push $start_msg
    call myprint
    add $4, %esp

get_input:
    call process_input
    call cal_a_count
    call cal_b_count
    call print_result

    cmpb $4, acount
    je win_game

    jmp get_input

win_game:
    push $right_msg
    call myprint
    add $4, %esp
    jmp reset_game

end_game:
    movl $0, %ebx
    movl $1, %eax
    int $0x80

//-----------------------------------------------------------------------------
.type process_input,@function
process_input:
    pushl %ebp
    movl %esp, %ebp

    movl $3, %eax
    movl $0, %ebx
    movl $input, %ecx
    movl $15, %edx
    int $0x80

    # add "\0"
    movl $0, %edi
arrange_input:
    cmpb $0x0a, (%ecx, %edi, 1)
    je arrange_enter

    incl %edi

    cmpl $4, %edi
    je arrange_end

    jmp arrange_input

arrange_enter:
    movb $0, (%ecx, %edi, 1)

arrange_end:
    addl $4, %ecx
    movb $0, (%ecx)

    cmpb $EXIT, input
    je end_game

    movl %ebp, %esp
    popl %ebp
    ret

//-----------------------------------------------------------------------------
.type myprint,@function
myprint:
    pushl %ebp
    movl %esp, %ebp

    # get msg address
    movl 8(%ebp), %ecx

    # get msg length
    movl $0, %edx

start_loop:
    cmpb $0, (%ecx)
    je end_loop

    incl %ecx
    incl %edx

    jmp start_loop

end_loop:
    movl $4, %eax
    movl $1, %ebx
    movl 8(%ebp), %ecx
    int $0x80

    movl %edx, %eax

    movl %ebp, %esp
    popl %ebp
    ret

//-----------------------------------------------------------------------------
.type cal_a_count,@function
cal_a_count:
    pushl %ebp
    movl %esp, %ebp

    movb $0, acount

    # cal xAxB
    movl $0, %edi

    movl $answer, %eax
    movl $input, %ebx

cal_a_count_loop:
    cmpl $4, %edi
    jge cal_a_end

    movb (%eax, %edi, 1), %ch
    movb (%ebx, %edi, 1), %cl

    incl %edi

    cmpb %ch, %cl
    je cal_a_equal

    jmp cal_a_count_loop

cal_a_equal:
    incb acount
    jmp cal_a_count_loop

cal_a_end:
    movl $result, %eax

    movb acount, %bl
    addb $CHARACTER_0, %bl

    movb %bl, A_COUNT_POS(%eax)

    movl %ebp, %esp
    popl %ebp
    ret

//-----------------------------------------------------------------------------
.type print_result,@function
print_result:
    push %ebp
    movl %esp, %ebp

    pushl $result
    call myprint
    add $4, %esp

    movl %ebp, %esp
    popl %ebp
    ret

//-----------------------------------------------------------------------------
.type cal_b_count,@function
cal_b_count:
    pushl %ebp
    movl %esp, %ebp

    movb $0, bcount

    # %edi -> input index
    # %esi -> loop index
    movl $0, %edi
    movl $0, %esi

cal_b_count_loop:
    cmpl $4, %esi
    jge cal_b_check_end

    cmpl %esi, %edi
    je cal_b_count_adjust

    # input now character
    movl $input, %eax
    movb (%eax, %edi, 1), %dl

    # answer now character
    movl $answer, %eax
    movb (%eax, %esi, 1), %dh

    incl %esi

    cmpb %dl, %dh
    je cal_b_equal

    jmp cal_b_count_loop

cal_b_count_adjust:
    incl %esi
    jmp cal_b_count_loop

cal_b_equal:
    incb bcount
    jmp cal_b_count_loop

cal_b_check_end:
    cmpl $4, %edi
    jge cal_b_end

    incl %edi
    movl $0, %esi

    jmp cal_b_count_loop

cal_b_end:
    movl $result, %eax

    movb bcount, %bl
    addb $CHARACTER_0, %bl

    movb %bl, B_COUNT_POS(%eax)

    movl %ebp, %esp
    popl %ebp
    ret

//-----------------------------------------------------------------------------
.type getrandom,@function
getrandom:
    pushl %ebp
    movl %esp, %ebp

    movl $13, %eax
    movl $nowsecond, %ebx
    int $0x80

    movl $0, %edx
    movl $100, %ebx
    divl %ebx

    imull $1103515245, %edx
    addl $12345, %edx

    movl %edx, %eax
    movl $0, %edx
    movl $65535, %ebx
    divl %ebx

    movl $0, %edx
    movl $32768, %ebx
    divl %ebx

    movl %edx, %eax
    movl $0, %edx
    movl $10, %ebx
    divl %ebx

    # result in %eax
    movl %edx, %eax

    movl %ebp, %esp
    popl %ebp
    ret

//-----------------------------------------------------------------------------
.type newanswer1,@function
newanswer1:
    pushl %ebp
    movl %esp, %ebp

    movl $0, %edi
    movl $digitlist, %eax
reset_list:
    cmpl $10, %edi
    jge reset_list_end

    movb not_used, %cl
    movb %cl, (%eax, %edi, 1)

    incl %edi
    jmp reset_list

reset_list_end:
    movl $0, %edi

getrandom_loop1:
    cmpl $4, %edi
    jge getrandom_loop_end1

    call getrandom

    movl %eax, %ecx

    movl $digitlist, %eax
    movb not_used, %dl
    cmpb %dl, (%eax, %ecx, 1)
    jne getrandom_loop1

    movl %ecx, %edx
    addb $CHARACTER_0, %dl

    # put digit in answer
    movl $answer, %eax
    movb %dl, (%eax, %edi, 1)

    # put digit in right_msg
    movl $right_msg, %eax
    addl $RES_ANS_POS, %eax
    movb %dl, (%eax, %edi, 1)

    # put digit in digitlist
    movl $digitlist, %eax
    movb %dl, (%eax, %ecx, 1)

    incl %edi

    jmp getrandom_loop1

getrandom_loop_end1:
    movl %ebp, %esp
    popl %ebp
    ret
