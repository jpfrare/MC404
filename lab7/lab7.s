.data 
input: .skip 8 #s0
output: .skip 8 #s1
decoded: .skip 4 #s2
coded: .skip 7 #s3

.text
.globl _start

read:
    #s0 é a string de input
    #a2 tem o número de bytes corretos para serem lidos
    li a0, 0 #stdin
    mv a1, s0 #copiando endereço em a1
    li a7, 63 #read pro syscall
    ecall
    ret

write:
    #s1 é a string de output
    #a2 tem o número de bytes corretos para serem escritos
    li a0, 1 #stdout
    mv a1, s1
    li a7, 64 #write pro syscall
    ecall
    ret

exit:
    li a7, 93 #saída para syscall
    ecall

stringBinaryConvertion:
    #a0 -> string 
    #a1 -> quantidade de caracteres a serem convertidos
    #a2 -> endereço dos bits
    #a3 -> 0 se binario para string e qualquer outra coisa para o contrário
    li t1, 0

    1:  
        beq a3, zero, binToStr

        strToBin:
            lb t0, 0(a0) #carregando caractere
            addi t0, t0, -'0' #convertendo para inteiro
            sb t0, 0(a2) #salvando no resultado
            j iteration
        
        binToStr:
            lb t0, 0(a2) #carregando bit
            addi t0, t0, '0' #convertendo para ascii
            sb t0, 0(a0) #salvando na string

        iteration:
        addi a0, a0, 1 #avançando na string
        addi a2, a2, 1 #avançando no resultado
        addi t1, t1, 1 #avançando na iteração

        blt t1, a1, 1b #retorna ao loop se t1 < a1

        ret
    
codify:
    #a0 -> bits nao codificados
    #a1 -> bits codificados

    lb t1, 0(a0) #d1
    lb t2, 1(a0) #d2
    lb t3, 2(a0) #d3
    lb t4, 3(a0) #d4

    #p1
    xor t0, t1, t2 #t0 = d1 xor d2
    xor t0, t0, t4 #t0 = d1 xor d2 xor d4 = p1
    sb t0, 0(a1) #salvando p1 no vetor de codificação

    #p2
    xor t0, t1, t3 #t0 = d1 xor d3
    xor t0, t0, t4 #t0 = d1 xor d3 xor d4 = p2
    sb t0, 1(a1) #salvando p2 no vetor de codificação

    sb t1, 2(a1) #salvando d1 no vetor de codificação

    #p3
    xor t0, t2, t3 #t0 = d2 xor d3
    xor t0, t0, t4 #t0 = d2 xor d3 xor d4 = p3
    sb t0, 3(a1) #salvando p3 no vetor de codificação

    #salvando os demais dígitos no vetor de codificação
    sb t2, 4(a1)
    sb t3, 5(a1)
    sb t4, 6(a1)

    ret

decodify:
    #a0 -> bits não codificados
    #a1 -> bits codificados
    #a2 -> quantidade de erros

    li a2, 0 #a2 começa com 0

    #carregando os bits
    lb t1, 2(a1) #t1 = d1
    lb t2, 4(a1) #t2 = d2
    lb t3, 5(a1) #t3 = d3
    lb t4, 6(a1) #t4 = d4

    #salvando os bits no vetor não-codificado
    sb t1, 0(a0)
    sb t2, 1(a0)
    sb t3, 2(a0)
    sb t4, 3(a0)

    p1:
    lb t5, 0(a1) #t5 = p1
    xor t0, t1, t2 #t0 = d1 xor d2
    xor t0, t0, t4 #t0 = d1 xor d2 xor d4 = p1
    beq t0, t5, p2 #vai diretamente para p2 se os valores conferirem

    addi a2, a2, 1 #adiciona 1 a quantidade de erros

    p2:
    lb t5, 1(a1) #t5 = p2
    xor t0, t1, t3 #t0 = d1 xor d3
    xor t0, t0, t4 #t0 = d1 xor d3 xor d4 = p2
    beq t0, t5, p3 #vai diretamente para p3 se os valores conferirem

    addi a2, a2, 1 #adiciona 1 na quantidade de erros

    p3:
    lb t5, 3(a1) #t5 = p3
    xor t0, t2, t3 #t0 = d2 xor d3
    xor t0, t0, t4 #t0 = d2 xor d3 xor d4 = p3
    beq t0, t5, end #vai diretamente para o fim da função se os valores de p3 conferirem

    addi a2, a2, 1 #adiciona 1 na quantidade de erros

    end:
        ret


_start:
    la s0, input
    la s1, output
    la s2, decoded
    la s3, coded

    #recendo o primeiro input:
    li a2, 5 #4 caracteres + '\n'
    jal read #s0 = &input (bits não codificados)

    #covertendo o input e salvando nos dados não codificados:
    mv a0, s0 #copiando input para a0
    li a1, 4 #quantidade de caracteres a serem convertidos
    mv a2, s2 #copiando bits não codificados para a2
    li a3, 1 #flag para converter de str para binário

    jal stringBinaryConvertion #s2 tem os dados não codificados

    #codificação:
    mv a0, s2 #não codificados -> a0
    mv a1, s3 #codificados -> a1

    jal codify #s3 tem os dados codificados

    #convertendo os dados codificados para string:
    mv a0, s1 #copiando output para a0
    li a1, 7 #7 caracteres a serem convertidos
    mv a2, s3 #copiando os dados codificados para a2
    li a3, 0 #flag para conversão de binário para str

    jal stringBinaryConvertion #s1 tem a string a ser escrita (output)
    
    #imprimindo o resultado:
    li a2, 8 #impressão de 8 caracteres
    li t0, '\n'
    sb t0, 7(s1) #carregando o byte de quebra de linha no output
    jal write
    
    #recebendo o segundo input:
    li a2, 8 #7 caracteres + '\n'
    jal read #s0 = input (bits codificados)

    #convertendo o input e salvando nos dados codificados
    mv a0, s0 #input em a0
    li a1, 7 #quantidade de caracteres a serem convertidos
    mv a2, s3 #copiando os bits codificados para s3
    li a3, 1 #flag para converter de str para binário

    jal stringBinaryConvertion #s3 tem os bits codificados

    #decodificação:
    mv a0, s2 #a0 -> não codificados
    mv a1, s3 #a1 -> codificados

    jal decodify #s2 tem os dados não codificados, a2 tem a quantidade de erros
    mv s4, a2 #salvando a quantidade de erros em s4

    #convertendo os dados não codificados para string:
    mv a0, s1 #copiando output para a0
    li a1, 4 #4 caracteres a serem convertidos
    mv a2, s2 #copiando os bits nao codificados para a2
    li a3, 0 #flag de conversão de binário para string

    jal stringBinaryConvertion #s1 tem a string a ser escrita (output)

    #imprimindo o resultado:
    li a2, 5 #impressão de 5 caracteres
    li t0, '\n' 
    sb t0, 4(s1) #carregando a quebra de linha no output
    jal write

    #imprimindo a quantidade de erros:
    addi s4, s4, '0' #convertendo para caractere
    sb s4, 0(s1) #salvando no output
    sb t0, 1(s1) #salvando a quebra de linha no output

    li a2, 2 #impressão de 2 caracteres
    jal write

    jal exit
