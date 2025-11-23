int read(int __fd, const void *__buf, int __n){
   int ret_val;
 __asm__ __volatile__(
   "mv a0, %1           # file descriptor\n"
   "mv a1, %2           # buffer \n"
   "mv a2, %3           # size \n"
   "li a7, 63           # syscall read code (63) \n"
   "ecall               # invoke syscall \n"
   "mv %0, a0           # move return value to ret_val\n"
   : "=r"(ret_val)  // Output list
   : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
   : "a0", "a1", "a2", "a7"
 );
 return ret_val;
}


void write(int __fd, const void *__buf, int __n)
{
 __asm__ __volatile__(
   "mv a0, %0           # file descriptor\n"
   "mv a1, %1           # buffer \n"
   "mv a2, %2           # size \n"
   "li a7, 64           # syscall write (64) \n"
   "ecall"
   :   // Output list
   :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
   : "a0", "a1", "a2", "a7"
 );
}


void exit(int code)
{
 __asm__ __volatile__(
   "mv a0, %0           # return code\n"
   "li a7, 93           # syscall exit (93) \n"
   "ecall"
   :   // Output list
   :"r"(code)    // Input list
   : "a0", "a7"
 );
}


void _start()
{
 int ret_code = main();
 exit(ret_code);
}


#define STDIN_FD  0
#define STDOUT_FD 1


int strToint(char * string, int index){
   int value = 0;


   for (int i = 1 + index; i <= 4 + index; i++){
       value = 10*value + (int)(string[i] - '0');
   }


   if (string[index] == '-') value *= -1;


   return value;
}


void inputToDec(char * input, int * vector){
   int index = 0;
   for (int i = 0; i < 30; i += 6){
     vector[index] = strToint(input, i);
     index++;
   }
}


int pack (int startbit, int endbit, int number) {
   int nBits = endbit - startbit + 1;
   int mask = (1 << nBits) - 1;
   number = mask & number;
   number <<= startbit;
  
   return number;
}


int sum (int * vector) {
   return pack(0, 2, vector[0]) + pack(3, 10, vector[1]) + pack(11, 15, vector[2]) + pack(16,20, vector[3]) + pack(21, 31, vector[4]);
}


void hex_code(int val){
   char hex[11];
   unsigned int uval = (unsigned int) val, aux;


   hex[0] = '0';
   hex[1] = 'x';
   hex[10] = '\n';


   for (int i = 9; i > 1; i--){
       aux = uval % 16;
       if (aux >= 10)
           hex[i] = aux - 10 + 'A';
       else
           hex[i] = aux + '0';
       uval = uval / 16;
   }
   write(1, hex, 11);
}






int main() {
   char buffer[35];
   int vector[5];
   read(STDIN_FD, buffer, 35);
   inputToDec(buffer, vector);
   hex_code(sum(vector));
   return 0;


}
