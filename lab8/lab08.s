.data
    inputFile: .asciz "image.pgm"
.bss 
    image: .skip 263000
    dimentions: .word 0, 0 #largura, altura
    char: .skip 1

.text
.globl _start

open:
    #a0 é o endereço
    li a1, 0 #flag -> não sei
    li a2, 0 #modo -> não sei2
    li a7, 1024 #open para syscall
    ecall
    ret #a0 agora tem o fd da imagem

close:
    #a0 tem ofile descriptor da imagem
    li a7, 57 #syscall close
    ecall

setCanvasSize:
    #a0 -> comprimento do canvas
    #a1 -> largura do canvas
    li a7, 2201 #syscall 
    ecall
    ret

setPixel:
    #a0 coordenada x do pixel
    #a1 coordenada y do pixel
    #a2 valor da cor / é literalmente a mesma do pixel que vc pegou
    li a7, 2200
    ecall 
    ret

read:
    #a0 -> file descriptor
    #a1 -> armazenamento do input
    #a2 -> tamanho input
    li a7, 63 # syscall read (63)
    ecall 
    ret


write:
    #a0 -> file descriptor
    #a1 -> output
    #a2 -> tamanho input
    li a7, 64           # syscall write (64)
    ecall


_start:
    la a0, inputFile
    jal open
    #a0 -> fd

    mv s0, a0 #s0 -> fd
    la s1, image #s1 -> &image
    la s3, dimentions #s3 -> &dimentions

    HeaderRead:
        li a7, 63 #syscall read
        mv a0, s0 #a0 -> fd
    
        li a1, 0 #lixo
        li a2, 3 #tamanho do lixo
        ecall #leu o lixo, vai começar o número agora

        la a1, char #caractere a ser lido
        li a2, 1 #numero de dígitos a serem lidos

        li t0, ' ' #comparador 1
        li t1, 10 #multiplicador

        #t2 = caractere a ser lido
        li a3, 0 #acumulador

        1:
            ecall #lendo o caractere, que está em a1
            lb t2, 0(a1) #carregando o caractere

            bne t2, t0, 1f #sai se t2 == ' '

            addi t2, t2, -'0' #transformando em inteiro

            mul a3, a3, t1 #a3 *= 10
            add a3, a3, t2 #a3 += t2

            j 1b

        1:

        sw a3, 0(s3) #guardando a largura na largura
        li t0, '\n' #novo comparador
        li a3, 0 #novo acumulador

        1:
            ecall #lendo o caractere, que está em a1
            lb t2, 0(a1) #carregando o caractere

            bne t2, t0, 1f #sai se t2 == '\n'

            addi t2, t2, -'0' #transformando em inteiro

            mul a3, a3, t1 #a3 *= 10
            add a3, a3, t2 #a3 += t2

            j 1b

        1:

        sw a3, 4(s3) #guardando a altura
        

