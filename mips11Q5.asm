.data
InstrMem: .word 0x012A4020
         .word 0x8C910004
         .word 0xACB20008
         .word 0x11290003
         .word 0x01400020
         .word 0x8C000010
         .word 0xAC13000C
         .word 0x003123AB
         .word 0xFFFFFFFF
RegUsage: .word 0:32
str_invalid: .asciiz "\nUnknown instruction at index "
str_warn_rs_eq_rt: .asciiz "\nWarning: rs == rt at index "
str_warn_rd_zero: .asciiz "\nWarning: attempt to write to $zero at index "
str_warn_rt_zero: .asciiz "\nWarning: attempt to write to $zero at index "
newline: .asciiz "\n"
twodotspace: .asciiz ": "
str_total: .asciiz "\nTotal instructions: "
str_valid: .asciiz "\nValid instructions: "
str_invalid_count: .asciiz "\nInvalid instructions: "
str_rtype: .asciiz "\nR-type instructions: "
str_itype: .asciiz "\nI-type instructions: "
str_warnings: .asciiz "\nWarnings: "
str_register_usage: .asciiz "\nRegister usage: "
str_register_prefix: .asciiz "\n$"
str_register_suffix: .asciiz "  - "
str_times: .asciiz " times"
str_time: .asciiz " time"

.text
.globl main
main:
    la   $s0, InstrMem
    li   $s1, 0
    li   $s2, 0
    li   $s3, 0
    li   $s4, 0
    li   $s5, 0
    li   $s6, 0
    li   $s7, 0

loop:
    lw   $t0, 0($s0)
    li   $t9, -1
    beq  $t0, $t9, PrintSummary
    addi $s2, $s2, 1
    move $a0, $t0
    jal  ClassifyInstruction
    beq  $v0, -1, mark_invalid
    addi $s3, $s3, 1
    beq  $v0, 0, mark_rtype
    beq  $v0, 1, mark_itype
    j    next

mark_rtype:
    addi $s5, $s5, 1
    move $a0, $t0
    jal  ExtractRegisters
    jal  CheckWarnings
    move $a0, $t0
    move $a1, $zero
    jal  CountRegisters
    j    next

mark_itype:
    addi $s6, $s6, 1
    move $a0, $t0
    jal  ExtractRegisters
    jal  CheckWarnings
    move $a0, $t0
    li   $a1, 1
    jal  CountRegisters
    j    next

mark_invalid:
    addi $s4, $s4, 1
    li   $v0, 4
    la   $a0, str_invalid
    syscall
    move $a0, $s1
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, twodotspace
    syscall
    move $a0, $t0
    li   $v0, 34
    syscall
    li   $v0, 4
    la   $a0, newline
    syscall
    j    next

next:
    addi $s0, $s0, 4
    addi $s1, $s1, 1
    j    loop

ClassifyInstruction:
    srl  $t1, $a0, 26
    beq  $t1, $zero, check_funct
    li   $t2, 4
    beq  $t1, $t2, itype
    li   $t2, 5
    beq  $t1, $t2, itype
    li   $t2, 35
    beq  $t1, $t2, itype
    li   $t2, 43
    beq  $t1, $t2, itype
    li   $t2, 8
    beq  $t1, $t2, itype
    li   $t2, 12
    beq  $t1, $t2, itype
    li   $t2, 13
    beq  $t1, $t2, itype
    li   $v0, -1
    jr   $ra

check_funct:
    andi $t3, $a0, 0x3F
    li   $t2, 0x20
    beq  $t3, $t2, rtype
    li   $v0, -1
    jr   $ra

rtype:
    li   $v0, 0
    jr   $ra

itype:
    li   $v0, 1
    jr   $ra

ExtractRegisters:
    srl  $t7, $a0, 26
    beq  $t7, $zero, extract_r
    j    extract_i

extract_r:
    srl  $t4, $a0, 11
    andi $t4, $t4, 0x1F
    srl  $t5, $a0, 21
    andi $t5, $t5, 0x1F
    srl  $t6, $a0, 16
    andi $t6, $t6, 0x1F
    jr   $ra

extract_i:
    li   $t4, -1
    srl  $t5, $a0, 21
    andi $t5, $t5, 0x1F
    srl  $t6, $a0, 16
    andi $t6, $t6, 0x1F
    jr   $ra

CheckWarnings:
    srl  $t1, $t0, 26
    li   $t2, 4
    seq  $t7, $t1, $t2
    beq  $t1, $zero, chk_rsrt_rtype
    bnez $t7, chk_rsrt_beq
    j    chk_rt_zero

chk_rsrt_rtype:
    seq  $t8, $t5, $t6
    bnez $t8, do_warn_rs_eq_rt
    j    chk_rt_zero

chk_rsrt_beq:
    seq  $t8, $t5, $t6
    bnez $t8, do_warn_rs_eq_rt
    j    chk_rt_zero

do_warn_rs_eq_rt:
    addi $s7, $s7, 1
    li   $v0, 4
    la   $a0, str_warn_rs_eq_rt
    syscall
    move $a0, $s1
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, twodotspace
    syscall
    move $a0, $t0
    li   $v0, 34
    syscall
    li   $v0, 4
    la   $a0, newline
    syscall
    jr   $ra

chk_rt_zero:
    li   $t2, 35
    seq  $t7, $t1, $t2
    seq  $t8, $t6, $zero
    and  $t9, $t7, $t8
    bnez $t9, do_warn_rt_zero
    beq  $t1, $zero, chk_rd_zero
    jr   $ra

chk_rd_zero:
    seq  $t8, $t4, $zero
    bnez $t8, do_warn_rd_zero
    jr   $ra

do_warn_rd_zero:
    addi $s7, $s7, 1
    li   $v0, 4
    la   $a0, str_warn_rd_zero
    syscall
    move $a0, $s1
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, twodotspace
    syscall
    move $a0, $t0
    li   $v0, 34
    syscall
    li   $v0, 4
    la   $a0, newline
    syscall
    jr   $ra

do_warn_rt_zero:
    addi $s7, $s7, 1
    li   $v0, 4
    la   $a0, str_warn_rt_zero
    syscall
    move $a0, $s1
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, twodotspace
    syscall
    move $a0, $t0
    li   $v0, 34
    syscall
    li   $v0, 4
    la   $a0, newline
    syscall
    jr   $ra

CountRegisters:
    la   $t7, RegUsage
    beqz $a1, count_rd
    j    count_rs_rt

count_rd:
    bltz $t4, count_rs_rt
    beqz $t4, count_rs_rt
    sll  $t8, $t4, 2
    add  $t9, $t7, $t8
    lw   $a2, 0($t9)
    addi $a2, $a2, 1
    sw   $a2, 0($t9)

count_rs_rt:
    sll  $t8, $t5, 2
    add  $t9, $t7, $t8
    lw   $a2, 0($t9)
    addi $a2, $a2, 1
    sw   $a2, 0($t9)
    sll  $t8, $t6, 2
    add  $t9, $t7, $t8
    lw   $a2, 0($t9)
    addi $a2, $a2, 1
    sw   $a2, 0($t9)
    jr   $ra

PrintSummary:
    li   $v0, 4
    la   $a0, str_total
    syscall
    move $a0, $s2
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, str_valid
    syscall
    move $a0, $s3
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, str_invalid_count
    syscall
    move $a0, $s4
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, str_rtype
    syscall
    move $a0, $s5
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, str_itype
    syscall
    move $a0, $s6
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, str_warnings
    syscall
    move $a0, $s7
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, str_register_usage
    syscall
    jal  PrintRegisterUsage
    li   $v0, 10
    syscall

PrintRegisterUsage:
    li   $t0, 0
    la   $t1, RegUsage
reg_loop:
    lw   $t2, 0($t1)
    beq  $t2, $zero, next_reg
    li   $v0, 4
    la   $a0, str_register_prefix
    syscall

    move $a0, $t0
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, str_register_suffix
    syscall

    move $a0, $t2
    li   $v0, 1
    syscall

    li   $t3, 1
    beq  $t2, $t3, sing
    li   $v0, 4
    la   $a0, str_times
    syscall
    j    after

sing:
    li   $v0, 4
    la   $a0, str_time
    syscall

after:
    li   $v0, 4
    la   $a0, newline
    syscall

next_reg:
    addi $t0, $t0, 1
    addi $t1, $t1, 4
    li   $t3, 32
    bne  $t0, $t3, reg_loop
    jr   $ra
