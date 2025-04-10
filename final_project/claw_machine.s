.text
    .align  2

start:
    # loop until r4 is set to 1 (the button has been pushed)
    # r4 is set to 1 when the button is pushed`
    nop
    nop
    beq     $r4,    0,      start

game:
    beq     $r5,    1,      up
    beq     $r6,    1,      down
    beq     $r7,    1,      right
    beq     $r8,    1,      left
    beq     $r9,    1,      move_claw
    j       game

up:
    beq     $r5,    0,      game
    addi    $r10,   $r10,   1           # signal to move up
    nop
    nop
    beq     $r5,    1,      up

down:
    beq     $r6,    0,      game
    addi    $r11,   $r11,   1           # signal to move down
    nop
    nop
    beq     $r6,    1,      down

right:
    beq     $r7,    0,      game
    addi    $r12,   $r12,   1           # signal to move right
    nop
    nop
    beq     $r7,    1,      right

left:
    beq     $r8,    0,      game
    addi    $r13,   $r13,   1           # signal to move left
    nop
    nop
    beq     $r8,    1,      left

move_claw:
    subi    $r4,    $r4,    1
    nop
    nop
    beq     $r4,    0,      start

