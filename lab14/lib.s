.set gpt, 0xFFFF0100
.set read_current_sys_time, 0x0
.set time_store, 0x4
.set inter_period, 0x8

.set midi, 0xFFFF0300
.set play_ch_note, 0x0
.set instrument_id, 0x2
.set note, 0x4
.set note_vel, 0x5
.set note_dur, 0x6

.bss
    .globl  _system_time
    _system_time: .skip 4 

    .skip 200
    program_stack:
    .skip 200
    isr_stack:

.text
.globl _start
.globl play_note

    play_note:  #a0 = channel, a1 = instrument_id, a2 = note, a3 = note_vel, a4 = note_dur
        li t0, midi         #midi adress
        sw a1, instrument_id(t0)
        sw a2, note(t0)
        sw a3, note_vel(t0)
        sw a4, note_dur(t0)
        sw a0, play_ch_note(t0)

        ret 


    isr:
        csrrw sp, mscratch, sp              #sp -> isr stack
        addi sp, sp, -64
        sw t0, 0(sp)
        sw t1, 4(sp)
        sw t2, 8(sp)
        sw t3, 12(sp)

        la t0, _system_time                 #loading _system_time  -> t0
        li t1, gpt                          #loading gpt -> t1

        li t2, 1
        sb t2, read_current_sys_time(t1)    #reading current system time

        1:                                  #looping till  register not zero
            lw t2, read_current_sys_time(t1)
            bnez t2, 1b
        
        li t2, 100                           #storing sys time in _system_time
        lw t3, 0(t0)                         #loading previous system time
        add t2, t2, t3                       #adding 100ms to previous system time
        sw t2, 0(t0)                         #defining new system time as the previous sum

        li t2, 100
        sw t2, inter_period(t1)              #setting next period

        lw t0, 0(sp)
        lw t1, 4(sp)
        lw t2, 8(sp)
        lw t3, 12(sp)
        addi sp, sp, 64
        csrrw sp, mscratch, sp
        mret



    _start:
    la t0, isr
    csrw mtvec, t0              #isr adress - mtvec

    la sp, program_stack        #program stack - sp

    la t0, isr_stack            
    csrw mscratch, t0           #isr stack - mscratch
    
    csrr t0, mstatus
    ori t0, t0, 0x8
    csrw mstatus, t0            #enabling CPU int handling


    csrr t0, mie
    li t1, 0x800
    or t0, t0, t1
    csrw mie, t0                #enabling CPU external int handling

    li t0, gpt
    li t1, 100
    sw t1, inter_period(t0)     #setting the gpt timer to 100ms

    jal main

    li a0, 0
    li a7, 93
    ecall

    
    