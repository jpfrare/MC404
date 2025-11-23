.set baseAdress, 0xFFFF0100
.set engineDir, 0x21
.set steeringWheel, 0x20


.bss
  .align 4
  .skip 256
  program_stack:
  .skip 256
  isr_stack:

.text
.align 4

int_handler:
  #conferir mcause interrupt (bit 31 -> 0) e mcause excode (0 a 30 -> 8)
  csrrw sp, mscratch, sp    #trocando pilha com mscratch
  addi sp, sp, -64
  sw t0, 0(sp)
  sw t1, 4(sp)
  sw t2, 8(sp)

  #não é uma interrupção de software -> só encerra kkkj
  csrr t0, mcause
  bltz t0, end
  addi t0, t0, -8
  bnez t0, end

  #não é a unica syscall que eu criei -> encerra também kkkj
  addi a7, a7, -10
  bnez a7, end

  #a0 = engine direction, a1 = sterring wheel angle, a7 = 10
  syscall_set_engine_and_steering:
    li t0, baseAdress
    mv t1, a0
    mv a0, zero

    #testando condições corretas
    li t2, -1
    blt t1, t2, end
    li t2, 1
    bgt t1, t2, end

    li t2, -127
    blt a1, t2, end
    li t2, 127
    bgt a1, t2, end

    li a0, 1 #passou de todas as condições incorretas -> a0 vale 1
    sb a1, steeringWheel(t0)
    sb t1, engineDir(t0)
    j end

  end:  
  csrr t0, mepc  # load return address (address of the instruction that invoked the syscall)
  addi t0, t0, 4 # adds 4 to the return address (to return after ecall)
  csrw mepc, t0  # stores the return address back on mepc

  lw t0, 0(sp)
  lw t1, 4(sp)
  lw t2, 8(sp)
  addi sp, sp, 64
  csrrw sp, mscratch, sp

  mret           # Recover remaining context (pc <- mepc)


.globl _start
_start:
  #declarar as pilhas do programa e do tratamento de exceções
  #guardar a rotina de tratamento no mtvec 
  #habilitar exceções e interrupções (mstatus.mie (bit 3), mie.meie (bit 11))
  #colocar a maquina em modo usuário (mstatus.mpp (bits 11 e 12))
  #colocar o endereço da rotina do usuário no mepc
  la t0, isr_stack
  csrw mscratch, t0
  la sp, program_stack

  la t0, int_handler
  csrw mtvec, t0

  csrr t0, mstatus
  ori t0, t0, 0x8
  csrw mstatus, t0
  csrr t0, mie
  li t1, 0x800
  or t0, t0, t1
  csrw mie, t0

  csrr t0, mstatus
  li t1, ~0x1800
  and t0, t0, t1
  csrw mstatus, t0
    
  la t0, user_main
  csrw mepc, t0

  mret

.globl control_logic
control_logic:
  # implement your control logic here, using only the defined syscalls
  addi sp, sp, -16
  sw a0, 0(sp)
  sw a1, 4(sp)
  sw a7, 8(sp)

  1:
    li a0, 1
    li a1, -15
    li a7, 10
    ecall
    beqz a0, 1b
  
  lw a0, 0(sp)
  lw a1, 4(sp)
  lw a7, 8(sp)
  addi sp, sp, 16
  ret


