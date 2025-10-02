.data
    inputFile: .asciz "image.pgm"
    fimage: .skip 263000
    image: .skip 263000
.bss 
    dimentions: .word 0, 0 #largura, altura
    char: .skip 1
    lixo: .skip 4

.text
.globl _start

imageRead:
    la a0, inputFile
    li a1, 0 #flag -> não sei
    li a2, 0 #modo -> não sei2
    li a7, 1024 #open para syscall
    ecall

    #movendo para registradores s os valores importantes
    mv s0, a0 #s0 -> fd
    la s1, dimentions #s1 -> &dimensoes

    #preparando o loop
    #a0 já tem o fd
    li a7, 63 #read syscall

    mv a0, s0
    li a2, 2 #ler o lixo
    la a1, lixo
    ecall

    #ajustando parâmetros
    la a1, char
    li a2, 1 #um char por vez

    #para conversão de números
    li a3, 0 #quantidade de números convertidos
    li t5, 2 #quantidade de números que devem ser lidos
    li t0, '0' #comparador
    

    loop:
        mv a0, s0
        ecall #caractere está em char -> a1 guarda o endereço de char
        lb t2, 0(a1) #carregando o caractere em t2
        blt t2, t0, loop #se t2 < '0', lê outro caractere
        bge a3, t5, end #se ja leu os 2 números importantes (largura e altura), sai do loop
        

        #leu um valor interessante:
        li t3, 0 #acumulador
        li t4, 10 #multiplicador

        1: #leitura de um número
            addi t2, t2, -'0' #transforma em int
            mul t3, t3, t4 #t3 *= 10
            add t3, t3, t2 #t3 += t2

            mv a0, s0
            ecall #le o proximo caractere
            lb t2, 0(a1) #carregando caractere em t2
            bge t2, t0, 1b #se t2 >= '0' -> ainda tem número pra ler, volta pro 1b
            #se não:
            addi a3, a3, 1 #adiciona a quantidade de números a serem lidos
            sw t3, 0(s1) #salva em s1
            addi s1, s1, 4 #soma que em s1, proximo número
            j loop #volta pro loop
            
    end:
        #o úlimo dígito lido foi o primeiro do maxval, que sabemos ser 255
        li a2, 3 #últimos 3 bytes do número
        la a1, lixo
        mv a0, s0
        ecall

        addi s1, s1, -8 #volta p primeira posição de s1
        lw t0, 0(s1) #carregando largura 
        lw t1, 4(s1) #carregando altura
        mul a2, t0, t1 #a2 = largura x altura
        la a1, image
        mv a0, s0
        ecall #leu toda a imagem

        mv a0, s0
        li a7, 57 #syscall para fechar arquivo
        ecall #fecha o arquivo de imagem
        ret

conv: #a0 = Ponteiro p Min, a1 = Largura de Min
    lbu t0, 0(a0) #carrega o primeiro byte (do meio)
    slli t0, t0, 3 #multiplica por 8

    li t2, 0 #acumulador

    sub a0, a0, a1 #Min desce uma linha
    addi a0, a0, -1 #Min desce uma coluna -> 0,0

    li t4, 0 #iterador
    li t3, 3 #tamanho da matriz

    1:
        lbu t1, 0(a0) #extrai valor
        add t2, t2, t1 #soma em t2
        addi t4, t4, 1 #nova iteração
        addi a0, a0, 1 #proxima coluna
        blt t4, t3, 1b
    
    debug:

    addi a0, a0, -1 #volta uma coluna
    add a0, a0, a1 #sobe uma linha

    lbu t1, 0(a0) #extrai valor
    add t2, t2, t1 #soma em t2

    add a0, a0, -2 #volta 2 colunas
    lbu t1, 0(a0) #extrai valor
    add t2, t2, t1 #soma em t2

    add a0, a0, a1 #sobe uma linha

    li t4, 0
    1:
        lbu t1, 0(a0) #extrai valor
        add t2, t2, t1 #soma em t2
        addi t4, t4, 1 #nova iteração
        addi a0, a0, 1 #proxima coluna
        blt t4, t3, 1b
    
    
    neg t2, t2 #troca o sinal
    add t0, t0, t2 #soma com t0 e guarda em t0

    li t1, 255 #t1 = 255

    blt t0, t1, 2f #se for menor que 255, pula
    mv a0, t1

    2:
    bge t0, zero, 3f #se for maior ou igual a zero, pula
    mv a0, zero

    3:
    mv a0, t0
    ret

apllyFilter:#s0 = &Min, s1 = &dimentions, s2 = &Mout
    addi sp, sp, -4
    sw ra, 0(sp)

    lw s3, 0(s1) #largura = s3
    lw s4, 4(s1) #altura = s4

    addi s6, s3, -1 #largura - 1 = s6
    addi s7, s4, -1 #altura - 1 = s7

    li s8, 0 #y
    loopy: #fory
        li s9, 0 #x

        loopx: #forx
            beq s8, zero, 1f #se s8 = y = zero
            beq s8, s7, 1f #se s8 = y = altura - 1
            beq s9, s6, 1f #se s9 = x = largura - 1 
            beq s9, zero, 1f #se s9 = x = 0 
            j 2f

            1: #carrega preto
            sb zero, 0(s2)
            j 3f

            2:
            mv a0, s0 #a0 = s0 (ponteiro para Min)
            mv a1, s3 #largura de Min
            jal conv
            sb a0, 0(s2) #guarda na resposta

            3:
            addi s0, s0, 1
            addi s2, s2, 1
            addi s9, s9, 1
            blt s9, s3, loopx

        addi s8, s8, 1
        blt s8, s4, loopy

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

imagePrint: #s1 = &dimentions, s0 = &image
    mv a3, s0 #imagem
    lw s2, 0(s1) #largura
    lw s3, 4(s1) #altura

    mv a0, s2 #largura
    mv a1, s3 #altura
    li a7, 2201 #syscall setCanvasSize
    ecall

    #addi s3, s3, -1 #altura iterável

    li t1, 0 #y = altura
    1: #fory
        li t0, 0 #x
        2: #forx
            #montando a cor
            lbu t2, 0(a3) #carregando byte

            slli t4, t2, 24 #R
            slli t5, t2, 16 #G
            slli t6, t2, 8  #B
            or t6, t6, t5
            or t6, t6, t4
            ori a2, t6, 0xff #R|G|B|A = a2

            mv a0, t0 #a0 = x
            mv a1, t1 #a1 = y
            li a7, 2200 #syscall setpixel
            ecall 

            addi a3, a3, 1 #proximo pixel
            addi t0, t0, 1 #x = x + 1
            blt t0, s2, 2b #vai para forx se x = t0 < largura

        addi t1, t1, 1 #sobe altura
        blt t1, s3, 1b #vai para fory se y < altura
    ret


_start:
    jal imageRead
    
    la s0, image #s0 = &image
    la s1, dimentions #s1 = &dimentions
    la s2, fimage #s2 = &fimage

    jal apllyFilter #filtro aplicado na fimage, s2 foi estragado

    la s0, fimage #imagem com filtro
    jal imagePrint

    #exit
    li a0, 0
    li a7, 93
    ecall
