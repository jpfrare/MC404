.data
input: .skip 20
output: .skip 20
number: .word 0
indexnumber: .word 0


.text

read: 
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input #buffer
    li a2, 20  # size (reads only 20 bytes)
    li a7, 63 # syscall read (63)
    ecall
    ret

write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output       #buffer
    Li a2, 20           #size
    li a7, 64           # syscall write (64)
    ecall
    ret

finish:
    li a0, 0
    li a7, 93
    ret


strToint:
    li t6, 10 #multiplicador
    li t0, ' ' #condicional de parada
    la t1, number #endereco do numero
    lw t2, 0(t1) #valor do número

    
    loop:
        lbu t4, 0(s0) #char
        addi t4, t4, -48
        mul t2, t2, t6
        addi t2, t2, t4 #novo valor do numero
        addi s0, s0, 1
        lbu t5, 0(s0)
    
    bne t5,t0, loop
    sw t2, 0(t1)

    addi s0, s0, 1
    ret

sqrt:
    la t0, number #endereco do numero
    lw t1, 0(t0) #valor do numero

    lw t2, 0(t0) #palpite
    li t4, 2 #divisor
    
    
    li t3, 0 #iteração
    li t6, 9 #fim da iteraçao
    loop:
        div t2, t2, t4 #divide o palpite por 2
        div t5, t1, t2 #divide o numero pelo palpite
        add t2, t2, t5 #soma ao palpite o palpite anterior + o numero/palpite
        div t2, t2, t4 #divide por 2
        addi t3, 1 #itera

    blt t3, t6, loop

    sw t2, 0(t0) #salv ao novo valor


.globl _start

_start:
    jal read #a1 está com o endereço do input
    la s0, input #ponteiro para a string
    addi s0, 1



    jal write
    jal finish
    ecall

