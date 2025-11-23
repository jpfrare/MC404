.set base, 0xFFFF0100
.set setWrite, 0x0
.set write, 0x1
.set setRead, 0x2
.set read, 0x3

.data
    buffer: .skip 64

.text
.globl _start

readByte: #return -> a0 = byte
    li t0, base
    li t1, 1

    sb t1, setRead(t0)

    1:
        lb t1, setRead(t0)
        bnez t1, 1b
    
    lb a0, read(t0)
    
    ret

writeByte: #input and return: a0 -> byte to be written
    li t0, base
    li t1, 1

    sb a0, write(t0)
    sb t1, setWrite(t0)

    1:
        lb t1, setWrite(t0)
        bnez t1, 1b
    
    ret

strToInt:  #a0 = string, a1 = strlen, return: a0 = corresponding int
    mv t0, zero             #acummulator
    li t1, 10               #multiplier         
    mv t2, zero

    li t5, 1
    lb t3, 0(a0)            #signal
    li t4, '-'
    bne t4, t3, 1f
    addi a1, a1, -1
    addi a0, a0, 1
    li t5, -1

    1:
        beq t2, a1, 1f      #t2 == strlen -> end
        lb t3, 0(a0)
        addi t3, t3, -'0'

        mul t0, t0, t1
        add t0, t0, t3

        addi a0, a0, 1
        addi t2, t2, 1
        j 1b

    1:

    mv a0, t0
    mul a0, a0, t5
    ret

IntToStr:   #a0 = buffer, a1 = int, a2 = base; return: a0 = stringTerminated in \n, a1 = strlen
    addi sp, sp, -64
    mv a3, zero
    mv t0, sp
    mv t3, zero             #flag

    bge a1, zero, 1f        #if number is base 10 and is negative, flag t3
    li t1, 10
    bne a2, t1, 1f
    neg a1, a1
    li t3, '-'


    1: #put digits into sp
        remu t1, a1, a2
        sb t1, 0(t0)

        divu a1, a1, a2
        addi t0, t0, 1
        addi a3, a3, 1

    bnez a1, 1b

    mv a1, a3                   #strlen
    addi t0, t0, -1
    mv t1, a0

    beq t3, zero, 1f
    sb t3, 0(t1)
    addi t1, t1, 1
    addi a1, a1, 1

    1: #converting digits to ascii and putting them into a0
        li t2, 10
        lb t3, 0(t0)

        blt t3, t2, 2f
        addi t3, t3, 55
        j 3f

        2:
        addi t3, t3, 48

        3:
        sb t3, 0(t1)
        addi t0, t0, -1
        addi a3, a3, -1
        addi t1, t1, 1

    bgt a3, zero, 1b

    li t0, '\n'             #putting \n into buffer
    sb t0, 0(t1)

    addi sp, sp, 64
    ret


readString: #input: a0 -> buffer // return a0 = String terminated with \n, a1 = strlen
    addi sp, sp, -16
    sw ra, 0(sp)

    mv a1, zero             #strLen

    1:
        sw a0, 4(sp)
        sw a1, 8(sp)
        jal readByte        #byte read -> a0

        mv t0, a0           #byte read -> t0
        li t1, '\n'         #comparator

        lw a0, 4(sp)
        lw a1, 8(sp)

        sb t0, 0(a0)        #storing byte into a0
        beq t0, t1, 1f      #end loop if \n == t0

        addi a0, a0, 1      #next position
        addi a1, a1, 1      #strlen++
        j 1b

    1:

    sub a0, a0, a1          #going to first position
    lw ra, 0(sp)
    addi sp, sp, 16

    ret

writeSTring:    #a0: string, a1: strlen
    addi sp, sp, -16
    sw ra, 0(sp)

    1: 
        sw a0, 4(sp)
        sw a1, 8(sp)

        lb a0, 0(a0)   #str byte
        jal writeByte  #a0 = byte written

        li t0, '\n'
        beq t0, a0, 1f

        lw a0, 4(sp)
        addi a0, a0, 1  #next position
        j 1b

    1:

    lw ra, 0(sp)
    addi sp, sp, 16
    ret



operation1:
    addi sp, sp, -16
    sw ra, 0(sp)

    la a0, buffer
    jal readString      #a0 -> string, a1 -> strlen

    jal writeSTring

    lw ra, 0(sp)
    addi sp, sp, 16

    ret

operation2:
    addi sp, sp, -16
    sw ra, 0(sp)

    la a0, buffer
    jal readString   #a0 -> string, a1 -> strlen
    
    mv a2, a0        #a2 -> string, 
    add a0, a2, a1   #a0 -> end of the string
    addi a0, a0, -1

    1:
        blt a0, a2, 1f      #a0 < a2 -> end

        sw a0, 4(sp)
        sw a1, 8(sp)
        sw a2, 12(sp)

        lb a0, 0(a0)        #stringbyte
        jal writeByte

        lw a0, 4(sp)
        lw a2, 12(sp)

        addi a0, a0, -1     #next str to write
        j 1b
        
    1:

    li a0, '\n'
    jal writeByte           #writing \n

    lw ra, 0(sp)
    addi sp, sp, 16

operation3:
    addi sp, sp, -16
    sw ra, 0(sp)

    la a0, buffer
    jal readString      #a0: string, a1: len
    jal strToInt        #a0: int

    mv a1, a0           #a1: int
    la a0, buffer       #a0 = buffer
    li a2, 16           #a2 = base

    jal IntToStr        #a0: string, a1: strlen
    jal writeSTring

    lw ra, 0(sp)
    addi sp, sp, 16
    ret

operation4:
    addi sp, sp, -32
    sw ra, 0(sp)

    la a0, buffer
    jal readString      #a0: string, a1: len

    li t0, ' '
    mv t1, zero         #len1
    mv t2, a0           

    1:
        lb t3, 0(t2)
        beq t3, t0, 1f  #len of the first number
        addi t1, t1, 1
        addi t2, t2, 1
        j 1b
    1:

    sw a0, 4(sp)        #first operand
    sw t1, 8(sp)        #len of first operand

    addi t3, t2, 3      
    sw t3, 12(sp)       #second operand

    addi t1, t1, 3
    sub t1, a1, t1
    sw t1, 16(sp)       #len of second operand

    lb t1, 1(t2)        
    sb t1, 20(sp)       #operator

    lw a0, 4(sp)
    lw a1, 8(sp)
    jal strToInt        #converting fisrt operand

    sw a0, 4(sp)        #first operand store

    lw a0, 12(sp)
    lw a1, 16(sp)
    jal strToInt        #converting second operand

    mv a1, a0           #a1 = second operand
    lw a0, 4(sp)        #a0 = first operand
    lb a2, 20(sp)       #operator

        li t0, '+'
        bne t0, a2, 1f
        add a1, a0, a1
        j 4f
    1:
        li t0, '-'
        bne t0, a2, 2f
        sub a1, a0, a1
        j 4f
    2:
        li t0, '*'
        bne t0, a2, 3f
        mul a1, a0, a1
        j 4f
    3:
        li t0, '/'
        bne t0, a2, 4f
        div a1, a0, a1
    
    4:
        la a0, buffer
        li a2, 10

        jal IntToStr    #a0 = string, a1 = len
        jal writeSTring

    lw ra, 0(sp)
    addi sp, sp, 32
    ret

_start:
    jal readByte

    addi sp, sp, -4
    sw a0, 0(sp)

    jal readByte            #reading \n

    lw a0, 0(sp)
    addi sp, sp, 4

    1:
        li t0, '1'
        bne t0, a0, 2f
        jal operation1
        j exit

    2:
        li t0, '2'
        bne t0, a0, 3f
        jal operation2
        j exit

    3:
        li t0, '3'
        bne t0, a0, 4f
        jal operation3
        j exit

    4:
        li t0, '4'
        bne t0, a0, exit
        jal operation4

    exit:
        li a0, 0
        li a7, 93
        ecall

