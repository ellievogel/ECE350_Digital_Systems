start:
    # make bitmasks
    addi    $r1,        $r0,        1                   # 1
    addi    $r2,        $r0,        1
    sll     $r2,        $r2,        1                   # 2
    addi    $r4,        $r0,        1
    sll     $r4,        $r4,        2                   # 4
    addi    $r8,        $r0,        1
    sll     $r8,        $r8,        3                   # 8
    addi    $r16,       $r0,        1
    sll     $r16,       $r16,       4                   # 16
    j       game

game:
    lw      $r10,        1000($r0)

    # $r3 = right
    and     $r3,        $r10,       $r1
    bne     $r3,        $r0,        right

    # $r5 = left
    and     $r5,        $r10,       $r2
    bne     $r5,        $r0,        left

    # $r7 = forwards
    and     $r7,        $r10,       $r4
    bne     $r7,        $r0,        forwards

    # $r9 = backwards
    and     $r9,        $r10,       $r8
    bne     $r9,        $r0,        backwards

    # $r11 = claw
    and     $r11,       $r10,       $r16
    bne     $r11,       $r0,        claw

right:
    lw      $r10,       1000($r0)
    and     $r3,        $r10,       $r1
    sub     $r12,       $r3,        $r0                 # temp = $r3
    bne     $r12,       $r0,        right_continue
    j       game
right_continue:
    j       right

left:
    lw      $r10,       1000($r0)
    and     $r5,        $r10,       $r2
    sub     $r12,       $r5,        $r0
    bne     $r12,       $r0,        left_continue
    j       game
left_continue:
    j       left

forwards:
    lw      $r10,       1000($r0)
    and     $r7,        $r10,       $r4
    sub     $r12,       $r7,        $r0
    bne     $r12,       $r0,        forwards_continue
    j       game
forwards_continue:
    j       forwards

backwards:
    lw      $r10,       1000($r0)
    and     $r9,        $r10,       $r8
    sub     $r12,       $r9,        $r0
    bne     $r12,       $r0,        backwards_continue
    j       game
backwards_continue:
    j       backwards

claw:
    lw      $r10,       1000($r0)
    and     $r11,       $r10,       $r16
    sub     $r12,       $r11,       $r0
    bne     $r12,       $r0,        claw_continue
    j       game
claw_continue:
    j       claw
