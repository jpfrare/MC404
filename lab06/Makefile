Flags = --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax 
Compiler = clang
Linker = ld.lld

.PHONY: all clean


all: prog.x

file1.o: file1.s 
	$(Compiler) $(Flags) file1.s -c -o file1.o

prog.x: file1.o
	$(Linker) file1.o -o prog.x

clean:
	rm -f *.o *.s *.x

