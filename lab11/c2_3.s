.text

.globl fill_array_int
.globl fill_array_short
.globl fill_array_char

fill_array_int:
    addi sp, sp, -416
    sw ra, 400(sp)

    mv a0, sp
    li t0, 0
    li t1, 100

    1:
        sw t0, 0(a0)
        addi a0, a0, 4
        addi t0, t0, 1
        blt t0, t1, 1b
    
    mv a0, sp

    jal mystery_function_int

    lw ra, 400(sp)
    addi sp, sp, 416

    ret

fill_array_short:
    addi sp, sp, -208
    sw ra, 200(sp)

    mv a0, sp
    li t0, 0
    li t1, 100

    1:
        sh t0, 0(a0)
        addi t0, t0, 1
        addi a0, a0, 2
        blt t0, t1, 1b
    
    mv a0, sp

    jal mystery_function_short

    lw ra, 200(sp)
    addi sp, sp, 208

    ret

fill_array_char:
    addi sp, sp, -112
    sw ra, 100(sp)

    mv a0, sp

    li t0, 0
    li t1, 100

    1:
        sb t0, 0(a0)
        addi a0, a0, 1
        addi t0, t0, 1
        blt t0, t1, 1b
    
    mv a0, sp

    jal mystery_function_char

    lw ra, 100(sp)
    addi sp, sp, 112

    ret