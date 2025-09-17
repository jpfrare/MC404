.data
input: .skip 20 #string de entrada 
output: .skip 5 #output -> conta o ' ' ou o '\n'
vector: .word 0



.text


read:
    li a0, 0 #stdin
    la a1, input #input to read
    li a2, 20 #20 bytes -> tamanho imput
    li a7, 63 #read pro syscall
    ecall
    ret

write:
    li a0, 1 #stdout
    la a1, output #string de saída
    li a2, 20 #20 bytes -> tamanho output
    li a7, 64 #write pro syscall
    ecall
    ret

strToint: #do jeito que está escrito, é melhor pegar todo o input e guardar no vetor (somando + 4 em s1 depois de cada chamada)
    #s0:  &(input[i])
    #s1:  &(numero)
    li t0, 10 #t0 = 10
    li t1, ' ' #t1 = ' '
    li a1, 0 #começa o número com 0
    
    2:  
        lbu a0, s0 #a0 = input[i]
        beq a0, t1, 2f #sai do loop se a0 == ' '
        addi a0, a0, -'0' #a0 -= 48 -> dígito da string
        mul a1, a1, t0 #a1 *= 10 -> multiplica o valor por 10
        add a1, a1, a0 #ai += a0 -> soma o valor pelo valor do dígito
        addi s0, 1 # &(input[i]) + 1 -> próximo caractere
        j 2b

    2:
    addi s0, 1 #pula o caractere do espaço
    sw a1, s1 #guarda em numero o valor de a1

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
        addi t1, 1 #t1 += 1
    
    blt t1, t0, 1b

    sw a2, s1 #numero = a2

intToStr:
    #s1: &(numero)
    #s2: &(output)
    lw a0, s1 #a0 = numero
    






        
        
    