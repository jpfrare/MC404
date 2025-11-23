.text

.globl swap_int
.globl swap_char
.globl swap_short

swap_int:
    lw t0, 0(a0)
    lw t1, 0(a1)

    sw t1, 0(a0)
    sw t0, 0(a1)

    mv a0, zero
    ret

swap_char:
    lbu t0, 0(a0)
    lbu t1, 0(a1)

    sb t1, 0(a0)
    sb t0, 0(a1)

    mv a0, zero
    ret

swap_short:
    lh t0, 0(a0)
    lh t1, 0(a1)

    sh t1, 0(a0)
    sh t0, 0(a1)

    mv a0, zero
    ret