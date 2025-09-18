
.data
input: .skip 20 #string de entrada -> s0
output: .skip 5 #output -> conta o ' ' ou o '\n' -> s2
number: .word 0 #s1



.text
.globl _start

read:
    li a0, 0 #stdin
    la s0, input #input to read
    mv a1, s0
    li a2, 20 #20 bytes -> tamanho imput
    li a7, 63 #read pro syscall
    ecall
    ret

write:
    li a0, 1 #stdout
    la s2, output #string de saída
    mv a1, s2
    li a2, 5 #5 bytes -> tamanho output
    li a7, 64 #write pro syscall
    ecall
    ret

_start:
    jal read #s0 <- &(input[0])
    la s1, number #s1 <- &number
    la s2, output #s2 <- &(output[0])
    li t0, '\n' #comparador
    

    1:
        jal strToint #s1 está com o input, s0 está no último caractere do dígito
        jal sqrt #s1 agora é a raiz quadrada do número
        jal intToStr #s2 está com a raiz quadrada versão string

        addi s0, s0, 1 #&(input[i + 1]) -> input[i] pode ser ' ' ou '\n'
        lbu t1, 0(s0) #t1 = input[i]

        sb t1, 4(s2) #output[j + 4] = input[i] = ' ' || '\n'
        jal write #printa a raiz quadrada com o espaço ou terminação
        
        addi s0, s0, 1 #&(input[i + 1]) -> começo do proximo número ou saiu do range
        beq t1, t0, 1f
        j 1b
    
    1:
        j exit    
        

exit:
    li a0, 0
    li a7, 93 #chamada de saída
    ecall

strToint: #pega uma string com um numero de 4 dígitos e tira o inteiro correspondente
    #s0:  &(input[i])
    #s1:  &(numero)
    li t0, 10 #t0 = 10
    li t1, 4 #t1 = 4
    li t2, 0 #t2 = 0
    li a1, 0 #começa o número com 0
    
    2:  
        beq t2, t1, 2f #sai do loop se t2 == 4 -> leu todo inteiro
        lbu a0, 0(s0) #a0 = input[i]
        addi a0, a0, -'0' #a0 -= 48 -> dígito da string
        mul a1, a1, t0 #a1 *= 10 -> multiplica o valor por 10
        add a1, a1, a0 #ai += a0 -> soma o valor pelo valor do dígito
        addi s0, s0, 1 # &(input[i + 1]) -> próximo caractere
        addi t2, t2, 1 #t2 += 1
        j 2b

    2:
    sw a1, 0(s1) #guarda em numero o valor de a1

    ret

sqrt:
    #s1: &(numero)
    li t0, 10 #t0 = 10
    li t1, 0 #t1 = 0
    lw a1, s1 #a1 = numero = y
    mv a2, a1 #a2 = a1 (cópia para a iteração) 

    1:
        srai a3, a2, 1 #a3 = palpite = a2/2 = k
        div a4, a1, a3 #a4 = a1/a3 = y/k
        add a2, a4, a3 #k <- k + y/k
        srai a2, a2, 1 #k <- k/2
        addi t1, t1, 1 #t1 += 1
    
    blt t1, t0, 1b

    sw a2, 0(s1) #numero = a2

    ret

intToStr:
    #s1: &(numero)
    #s2: &(output[0])
    mv s3, s2  #s3 <- &(output[0])
    addi s3, s3, 3 #&(output[3])
    lw a0, s1 #a0 = numero
    li t0, 10 #t0 = 10


    1:
        rem a1, a0, t0 #a1 = a0%10
        addi a1, a1, '0' #a1 += '0' -> valor ascii
        sb a1, 0(s3) #output[i] = a1
        beq s3, s2, 1f
        div a0, a0, t0 #a0 /= 10
        addi s3, s3, -1 #&(output[i-1])
        j 1b
    
    1:
        #s2 && s3 <- &(output[0])
        ret

