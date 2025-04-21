start:
    # Bitmask definitions:
    # Bit 0 = Right
    # Bit 1 = Left
    # Bit 2 = Forwards
    # Bit 3 = Backwards
    # Bit 4 = Claw

    # Make bitmasks
    addi    $r1,    $r0,    1              # 1
    addi    $r2,    $r0,    1
    sll     $r2,    $r2,    1              # 2
    addi    $r4,    $r0,    1
    sll     $r4,    $r4,    2              # 4
    addi    $r8,    $r0,    1
    sll     $r8,    $r8,    3              # 8
    addi    $r16,   $r0,    1
    sll     $r16,   $r16,   4              # 16
    addi    $r20,   $r0,    1              # Used to subtract and clear signal

    j       game

game:
    lw      $r10,   1000($r0)

    # Right
    and     $r3,    $r10,   $r1
    bne     $r3,    $r0,    right_setup

    # Left
    and     $r5,    $r10,   $r2
    bne     $r5,    $r0,    left_setup

    # Forwards
    and     $r7,    $r10,   $r4
    bne     $r7,    $r0,    forwards_setup

    # Backwards
    and     $r9,    $r10,   $r8
    bne     $r9,    $r0,    backwards_setup

    # Claw
    and     $r11,   $r10,   $r16
    bne     $r11,   $r0,    claw_setup

    j       game


# === Right ===
right_setup:
    addi    $r6,    $r0,    1              # Set right signal flag
    j       right

right:
    lw      $r10,   1000($r0)
    and     $r3,    $r10,   $r1
    sub     $r12,   $r3,    $r0
    bne     $r12,   $r0,    right_continue

    sub     $r6,    $r6,    $r20           # Clear signal
    j       game

right_continue:
    j       right


# === Left ===
left_setup:
    addi    $r13,   $r0,    1              # Set left signal flag
    j       left

left:
    lw      $r10,   1000($r0)
    and     $r5,    $r10,   $r2
    sub     $r12,   $r5,    $r0
    bne     $r12,   $r0,    left_continue

    sub     $r13,   $r13,   $r20           # Clear signal
    j       game

left_continue:
    j       left


# === Forwards ===
forwards_setup:
    addi    $r14,   $r0,    1              # Set forwards signal flag
    j       forwards

forwards:
    lw      $r10,   1000($r0)
    and     $r7,    $r10,   $r4
    sub     $r12,   $r7,    $r0
    bne     $r12,   $r0,    forwards_continue

    sub     $r14,   $r14,   $r20           # Clear signal
    j       game

forwards_continue:
    j       forwards


# === Backwards ===
backwards_setup:
    addi    $r15,   $r0,    1              # Set backwards signal flag
    j       backwards

backwards:
    lw      $r10,   1000($r0)
    and     $r9,    $r10,   $r8
    sub     $r12,   $r9,    $r0
    bne     $r12,   $r0,    backwards_continue

    sub     $r15,   $r15,   $r20           # Clear signal
    j       game

backwards_continue:
    j       backwards


# === Claw ===
claw_setup:
    addi    $r17,   $r0,    1              # Set claw signal flag
    j       claw

claw:
    lw      $r10,   1000($r0)
    and     $r11,   $r10,   $r16
    sub     $r12,   $r11,   $r0
    bne     $r12,   $r0,    claw_continue

    sub     $r17,   $r17,   $r20           # Clear signal
    j       game

claw_continue:
    j       claw
