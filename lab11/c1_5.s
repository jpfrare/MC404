.text
.globl operation

operation:
    lw t0, 0(sp)        #i
    lw t1, 4(sp)        #j
    lw t2, 8(sp)        #k
    lw t3, 12(sp)       #l
    lw t4, 16(sp)       #m
    lw t5, 20(sp)       #n

    sw a5, 0(sp)        #f
    sw a4, 4(sp)        #e
    sw a3, 8(sp)        #d
    sw a2, 12(sp)       #c
    sw a1, 16(sp)       #b
    sw a0, 20(sp)       #a

    mv a0, t5
    mv a1, t4
    mv a2, t3
    mv a3, t2
    mv a4, t1
    mv a5, t0           #i

    mv t0, a6           #g
    mv t1, a7           #h

    mv a6, t1
    mv a7, t0

    sw ra, 24(sp)
    jal mystery_function

    lw ra, 24(sp)
    ret



