start:
    # loop until r4 is set to 1 (the button has been pushed)
    nop
    nop

    # query until button pressed
    # lw $r4 $rwhatever means button pressed
    bne     $r4,        $r0,    after_start
    j       start

after_start:
    addi    $r1,        $r1,    1

game:
    bne     $r5,        $r1,    check_down
    j       up

check_down:
    bne     $r6,        $r1,    check_right
    j       down

check_right:
    bne     $r7,        $r1,    check_left
    j       right

check_left:
    bne     $r8,        $r1,    check_move_claw
    j       left

check_move_claw:
    bne     $r9,        $r1,    game
    j       move_claw

up:
    bne     $r5,        $r1,    game
    addi    $r10,       $r10,   1               # signal to move up
    nop
    nop
    j       up

down:
    bne     $r6,        $r1,    game
    addi    $r11,       $r11,   1               # signal to move down
    nop
    nop
    j       down

right:
    bne     $r7,        $r1,    game
    addi    $r12,       $r12,   1               # signal to move right
    nop
    nop
    j       right

left:
    bne     $r8,        $r1,    game
    addi    $r13,       $r13,   1               # signal to move left
    nop
    nop
    j       left

move_claw:
    addi    $r4,        $r4,    -1              # replacing subi
    nop
    nop
    bne     $r4,        $r0,    move_claw
    j       start
