.data
    inputFile: .asciz "image.pgm"
    matrix: .word -1, -1, -1, -1, 8, -1, -1, -1, -1
.bss 
    image: .skip 263000
    fimage: .skip 263000
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
        ecall #leu toda a imagem, supostamente

        mv a0, s0
        li a7, 57 #syscall para fechar arquivo
        ecall #fecha o arquivo de imagem
        ret

createBlackBorder:#s0 = &imagem, s1 = &dimentions
    mv a0, s0 #imagem
    lw a1, 0(s1) #largura
    lw a2, 4(s1) #altura

    li t0, 0 #x

    1: #preto para y = 0
        sb zero, 0(a0)
        addi a0, a0, 1 #proximo pixel
        addi t0, t0, 1 #x += 1
        blt t0, a1, 1b
    
    
    li t1, 1 #y = 1
    addi t3, a1, -1 #t3 = largura - 1
    addi t4, a2, -1 #t4 = altura -1
    

    1: #preto para  1 <= y < altura - 1 e x = 0 ou x = largura - 1
        sb zero, 0(a0) #m[0][y] = 0
        add a0, a0, t3 #pula largura - 1 em x
        sb zero, 0(a0) #m[largura - 1][y] = 0

        addi a0, a0, 1 #m[0][y+1]
        addi t1, t1, 1 #y += 1
        blt t1, t4, 1b #volta pra 1 se y < altura - 1
    
    #y = altura - 1
    li t0, 0 #x = 0
    
    1: #preto para y = altura - 1
        sb zero, 0(a0)
        addi a0, a0, 1
        addi t0, t0, 1
        blt t0, a1, 1b
    
    ret

apllyFilter:#s0 = &Min, s1 = &dimentions, s2 = &Mout
    la s3, matrix #w
    lw a0, 0(s1) #a0 = largura
    lw a1, 4(s1) #a1 = altura

    #s0 = Min[0][0] início
    add s2, s2, a0 #Mout[0][1]
    addi s2, s2, 1 #s2 = Mout[1][1]

    addi a2, a0, -1 #a2 = largura - 1
    addi a3, a1, -1 #a3 = altura - 1

    li t0, 1 #i = 1
    1: #fori
        li t1, 1
        2: #forj
            #aplicando filtro no elemento
            mv a4, s0 #copiando a4 = Min[i - 1][j - 1] 
            mv a5, s3 #a5 = w[0][0]

            li a6, 0 #acumulador
            li t4, 3 #tamanho filtro

            li t2, 0 #k = 0
            3: #fork
                li t3, 0 #q = 0
                4: #forq
                    lw t5, 0(a5) #filtro[k][q]
                    lbu t6, 0(a4) #Min[i + k - 1][j + q - 1]
                    mul t5, t5, t6 #w[k][q]*Min[i + k - 1][j + q - 1]
                    add a6, a6, t5 #a6 += w[k][q]*Min[i + k - 1][j + q - 1]

                    addi t3, t3, 1 #q += 1
                    addi a5, a5, 4 #w[k][q+1]
                    addi a4, a4, 1 #Min[i + k - 1][i + q]
                    blt t3, t4, 4b #vai pra 4 se q < 3

                addi a4, a4, -3 # Min[i + k - 1][j - 1]
                add a4, a4, a0 #Min[i + k][j - 1]
                addi t2, t2, 1 #k + =1
                blt t2, t4, 3b

            #a6 está com o valor
            li t2, 255 #comparador
            blt zero, a6, 3f #se 0 < a6, pula
            mv a6, zero #se não a6 == 0

            3:
            bge t2, a6, 3f #se 255 >= a6, pula
            mv a6, t2 #se não a6 == 255

            3:
            sb a6, 0(s2) #salvando a6 em Mout[i][j]
            addi s2, s2, 1 #Mout[i][j + 1]
            addi t1, t1, 1 #j += 1
            addi s0, s0, 1 #Min[i][j + 1]

            blt t1, a2, 2b #se j < largura - 1, volta pra forj
        
        addi s2, s2, 2 #Mout[i +1][j]
        addi s0, s0, 2 #Min[i + 1][j]
        addi t0, t0, 1 #i += 1
        blt t0, a3, 1b #se i < altura - 1, volta para fori
    
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
    #s1 está dimenstions
    la s0, image #s0 = &image
    debug:
    jal createBlackBorder #criar borda preta -> s0 -> &imagem, mas com a borda preta
    debug1:
    la s2, fimage #s2 = &fimage
    jal apllyFilter #filtro asplicado na fimage, s2 foi estragado

    la s0, fimage #imagem com filtro
    jal imagePrint

    #exit
    li a0, 0
    li a7, 93
    ecall

        
