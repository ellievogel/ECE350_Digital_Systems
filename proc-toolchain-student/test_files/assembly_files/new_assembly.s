main:
    jal     read_mem

    addi    $a0,        $0,     0                   # Clear signal
    jal     write_mem

    addi    $r1,        $0,     1                   # 1 right
    and     $r3,        $r14,   $r1
    bne     $r3,        $0,     right_setup

    addi    $r2,        $0,     1                   # 2 left
    sll     $r2,        $r2,    1
    nop
    nop
    and     $r5,        $r14,   $r2
    bne     $r5,        $0,     left_setup

    addi    $r4,        $0,     1                   # 4 forwards
    sll     $r4,        $r4,    2
    and     $r7,        $r14,   $r4
    bne     $r7,        $0,     forwards_setup

    addi    $r8,        $0,     1                   # 8 backwards
    sll     $r8,        $r8,    3
    and     $r9,        $r14,   $r8
    bne     $r9,        $0,     backwards_setup

    addi    $r16,       $0,     1                   # 16 claw
    sll     $r16,       $r16,   4
    and     $r11,       $r14,   $r16
    bne     $r11,       $0,     claw_setup

    addi    $r12,       $0,     1
    sll     $r12,       $r12,   5
    and     $r13,       $r14,   $r12
    bne     $r13,       $0,     clear

    j       main

write_mem:
    sw      $a0,        20($0)
    jr      $ra

read_mem:
    lw      $r14,       10($0)
    jr      $ra

right_setup:
    addi    $a0,        $0,     1
    jal     write_mem
    j       right

right:
    jal     read_mem
    and     $r3,        $r14,   $r1
    bne     $r3,        $0,     right_continue
    addi    $a0,        $0,     0
    jal     write_mem                               # Clear signal
    j       main

right_continue:
    j       right

left_setup:
    addi    $a0,        $0,     2
    jal     write_mem
    j       left

left:
    jal     read_mem
    and     $r5,        $r14,   $r2
    bne     $r5,        $0,     left_continue
    addi    $a0,        $0,     0
    jal     write_mem                               # Clear signal
    j       main

left_continue:
    j       left

forwards_setup:
    addi    $a0,        $0,     4
    jal     write_mem
    j       forwards

forwards:
    jal     read_mem
    and     $r7,        $r14,   $r4
    bne     $r7,        $0,     forwards_continue
    addi    $a0,        $0,     0
    jal     write_mem                               # Clear signal
    j       main

forwards_continue:
    j       forwards

backwards_setup:
    addi    $a0,        $0,     8
    jal     write_mem
    j       backwards

backwards:
    jal     read_mem
    and     $r9,        $r14,   $r8
    bne     $r9,        $0,     backwards_continue
    addi    $a0,        $0,     0
    jal     write_mem                               # Clear signal
    j       main

backwards_continue:
    j       backwards

claw_setup:
    addi    $a0,        $0,     16
    jal     write_mem
    j       claw

claw:
    jal     read_mem
    and     $r11,       $r14,   $r16
    bne     $r11,       $0,     claw_continue
    addi    $a0,        $0,     0
    jal     write_mem                               # Clear signal
    j       main

claw_continue:
    j       claw

clear:
    addi    $a0,        $0,     0
    jal     write_mem                               # Clear signal
    j       main