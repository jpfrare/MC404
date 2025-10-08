.text
.globl puts
.globl gets
.globl itoa
itoa:
ret
.globl atoi
atoi:
ret
.globl linked_list_search
linked_list_search:
ret
.globl exit

strlen: #a0 -> string
    addi sp, sp, -16
    sw fp, 0(sp)
    add fp, sp, 16

    mv t0, a0           #copies string to t0
    li t1, 0            #strlen -> start 0
    mv t2, zero         #comparator

    1:
        sb t3, 0(t0)    #loads string byte
        beq t3, t2, 1f  #goes to 1f if \0 is read
        addi t1, t1, 1  #addi 1 to strlen cc
        j 1b            #back to loop
    1:

    mv a0, t1           #moves t1 to a0 -> return registrator

    lw fp, 0(sp)
    addi sp, sp, 16
    ret                 

puts:   #a0 -> string
    addi sp, sp, -16
    sw fp, 0(sp)
    sw ra, 4(sp)
    sw a0, 8(sp)
    addi fp, sp, 16

    jal strlen         #a0 now has the strlen
    mv t0, a0          #t0 -> strlen
    lw a0, 8(sp)       #a0 -> string

    li t1, '\n'        #load \n
    mv t2, zero        #load \0

    add a0, a0, t0     #goes to the string[len] 
    sb t1, 0(a0)       #replaces \0 for \n
    sub a0, a0, t0     #goes back to string[0]

    li a0, 1           #file descriptor
    mv a1, a0          #file to write
    addi a2, t0, 1     #len + 1 characters to write
    li a7, 64          #syscall write

    ecall
    mv t3, a0          #retval -> number of written chars

    lw a0, 4(sp)       #a0 -> string
    add a0, a0, t0     #goes to string[len]
    sb t2, 0(a0)       #replaces \n for \0
    sub a0, a0, t0     #goes back to string[0]

    mv a0, t3          #returns number of written chars

    lw ra, 4(sp)
    lw fp, 0(sp)       
    addi sp, sp, 16
    ret

gets:   #a0 -> string
    addi sp, sp, -16
    sw fp, 0(sp)
    sw ra, 4(sp)
    sw a0, 8(sp)
    addi fp, sp, 16 

    li a7, 63         #read syscall
    li a0, 0          #stdin
    mv a1, a0         #buffer 
    li a2, 1          #size

    li t0, '\n'
    1:  #reading loop
        ecall
        lb t1, 0(a1)
        beq t1, t2, 1f  #if the read byte is \n -> finished reading, goes to 1f
        addi a1, a1, 1  #else -> goes to the next position
        j 1b

    1:

    mv t0, zero
    sb t0, 0(a1)     #replaces \n for \0

    lw a0, 8(sp)     #return value -> string

    lw fp, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 16
    ret


exit:
    li a0, 0
    li a7, 93
    ecall
