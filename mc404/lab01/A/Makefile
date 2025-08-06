Flags = --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax 
Compiler = clang
Linker = ld.lld

.PHONY: all clean


all: prog.x

file1.s: file1.c
	$(Compiler) $(Flags) file1.c -S -o file1.s

file2.s: file2.c 
	$(Compiler) $(Flags) file2.c -S -o file2.s

file1.o: file1.s 
	$(Compiler) $(Flags) file1.s -c -o file1.o

file2.o: file2.s 
	$(Compiler) $(Flags) file2.s -c -o file2.o

prog.x: file1.o file2.o
	$(Linker) file1.o file2.o -o prog.x

clean:
	rm -f *.o *.s *.x

