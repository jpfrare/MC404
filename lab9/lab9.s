.data
    buffer: .skip 7
    
.text
.globl _start

read: #a0 -> número de bytes lidos
    li a0, 0
    la a1, buffer
    li a2, 7
    li a7, 63

    ecall
    ret

strToInt: #a0 -> string
    li t0, 0            #acumulador
    li t1, '\n'         #condição de parada
    li t2, 10           #multiplicador

    lb t3, 0(a0)        #primeiro byte
    li t4, '-'          #comparador

    bne t3, t4, 1f      #sinal do número (string[0] != '-' -> 1f)
    li t4, -1
    addi a0, a0, 1      #avança 1 posição -> começa o número
    j 2f

    1:
    li t4, 1            #número positivo

    2:                  #loop
    lb t3, 0(a0)
    beq t3, t1, 3f      #se t3 == '\n' -> acabou o número -> sai do loop
    addi t3, t3, -'0'   #conversão inteira
    mul t0, t0, t2      #t0 *= 10
    add t0, t0, t3      #t0 += t3 (byte convertido)

    addi a0, a0, 1      #próximo dígito
    j 2b

    3:
    mul t0, t0, t4      #sinal
    mv a0, t0           #a0 = t0
    ret

searchLinkedList: #a0 -> endereço do nó, #a1 -> soma desejada, #a2 -> número do nó

    bne a0, zero, 1f     #acabou a lista ligada e ainda não achou -> retorna -1
    li a0, -1
    ret

    1:
    lw t0, 0(a0)
    lw t1, 4(a0)
    add t1, t1, t0

    beq t1, a1, 2f      #soma bateu -> retorna

    lw a0, 8(a0)        #próximo endereço de memória
    addi a2, a2, 1      #avança mais 1
    j searchLinkedList

    2:
    mv a0, a2           #retorno -> valor do número do nó
    ret


printnumber:            #a0 -> número, #a1 -> buffer
    li t0, '\n'

    bge a0, zero, 1f    #a0 < 0 -> retorna -1 
        li t1, '-'
        li t2, '1'
        sb t1, 0(a1)
        sb t2, 1(a1)
        sb t0, 2(a1)
        li a2, 3
        j 2f

    1:  #número positivo, pode ser qualquer um 
        addi a1, a1, 4  #vai p quarta posição           
        sb t0, 0(a1)    #salvando o \n no fim
        li a2, 1        #número de dígitos -> 0 (conta \n)
        li t0, 10       #10

        loop:
            addi a1, a1, -1         #início do print--
            addi a2, a2, 1          #número de dígitos++
            rem t1, a0, t0          #t0 = a0%10
            addi t1, t1, '0'        #transforma em int
            sb t1, 0(a1)
            div a0, a0, t0

            bne a0, zero, loop      #volta pro loop se a1 for zero
    
    2:
    
        li a0, 1
        li a7, 64
        ecall
        ret



_start:
    jal read
    la a0, buffer
    jal strToInt

    mv a1, a0         #soma desejada
    
    la a0, head_node      #carrega a cabeça da lista
    li a2, 0

    jal searchLinkedList  #valor de retorno está em a0
    debug:
    la a1, buffer
    jal printnumber       #imprime o número do nó

    li a0, 0           #sucesso
    li a7, 93
    ecall


                

    
    