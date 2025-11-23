.text
.globl middle_value_int
.globl middle_value_short
.globl middle_value_char
.globl value_matrix

middle_value_int: #a0 -> array, a1 -> n
    srli a1, a1, 1
    slli a1, a1, 2

    add a0, a0, a1
    lw a0, 0(a0)

    ret


middle_value_short:
    li t0, 2

    div a1, a1, 2
    mul a1, a1, 2

    add a0, a0, a1
    lh a0, 0(a0)

    ret

middle_value_char:
    srli a1, a1, 1

    add a0, a0, a1
    lbu a0, 0(a0)

    ret


value_matrix: #a0 -> matrix, a1 -> i, a2 -> j
    li t0, 42 #number of collums

    mul t0, t0, a1
    add t0, t0, a2
    slli t0, t0, 2

    add a0, a0, t0
    lw a0, 0(a0)

    ret

