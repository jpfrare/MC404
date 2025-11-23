.text
.globl operation

operation:
    lw t0, 8(sp)        #t0 = k
    lw t1, 16(sp)       #t1 = m

    add a0, a1, a2      #a0 = b + c
    sub a0, a0, a5      #a0 = b + c - f
    add a0, a0, a7      #a0 = b + c - f + h
    add a0, a0, t0      #a0 = b + c - f + h + k
    sub a0, a0, t1      #a0 = b + c - f + h + k - m
    ret