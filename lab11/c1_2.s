.text
.globl my_function

my_function: #a0 = a, a1 = b, a2 = c
    addi sp, sp, -32
    sw fp, 0(sp)
    sw ra, 4(sp)
    addi fp, sp, 32


    #stack saving
    sw a0, 8(sp)
    sw a1, 12(sp)
    sw a2, 16(sp)

    add t0, a0, a1              #t0 = a + b
    mv t1, a0                   #t1 = a

    mv a0, t0                   #a0 = a + b
    mv a1, t1                   #a1 = a

    jal mystery_function        #a0 -> mistery_function(a+b, a)

    lw t0, 12(sp)               #t0 = b
    sub t0, t0, a0              #t0 = b - mistery_function(a+b, a)
    lw t1, 16(sp)               #t1 = c

    add t0, t0, t1              #t0 = aux = b - mistery_function(a+b, a) + c

    sw t0, 20(sp)               #storing aux

    mv a0, t0                   #a0 = aux
    lw a1, 12(sp)               #a1 = b

    jal mystery_function        #a0 = mistery_function(aux, b)

    lw t0, 16(sp)               #t0 = c
    sub a0, t0, a0              #t0 = c - mistery_function(aux, b)

    lw t0, 20(sp)

    add a0, a0, t0              #a0 = c - mistery_function(aux,b) + aux

    lw fp, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 32
    ret