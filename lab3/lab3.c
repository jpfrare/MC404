struct String {
    char seq[35];
    int len;

};

void swap(char * a, char * b) {
    char temp = *(a);
    (*a) = (*b);
    (*b) = temp;
}

int arrayLen(unsigned int number, int base) {
    int len = 0;

    do {
        number /= base;
        len++;
    } while (number != 0);

    return len + 3;
}

void prepareSwapping(struct String * hex, struct String * sHex) {//tem que colocar numero ate len ser 10
    int len = hex->len - 1;
    
    sHex->seq[0] = '0';
    sHex->seq[1] = 'x';

    int numberzeroes = 10 - len;
    int indexf = 2;
    for (int i = 0; i < numberzeroes; i++) {
        sHex->seq[indexf] = '0';
        indexf++;
    }
    int indexh = 2;
    while (hex->seq[indexh] != '\n') {
        sHex->seq[indexf] = hex->seq[indexh];
        indexf++;
        indexh++;
    }
    sHex->len = indexf + 1;
    sHex->seq[indexf] = '\n';

}

void endianSwap(struct String * hex) {
    int len = hex->len;
    
    for (int i = 2; i < (len - 3)/2 + 2; i += 2) {
        swap(&(hex->seq[i]), &(hex->seq[len - i - 1]));
        swap(&(hex->seq[i + 1]), &(hex->seq[len - i]));
    }
}

int hexToDecimal(char * hex) {
    int decimal = 0;
    int index = 2;
    while (hex[index] != '\n'){
        int value;
        if (hex[index] <= '9') value = (int)(hex[index] - '0');
        else value = (int)(hex[index] - 'a' + 10);

        decimal = 16*(decimal) + value;
        index++;
    }

    return decimal;
}

void decimalToBinary(int number, struct String * bin) {
    unsigned int uNumber = (unsigned int)(number);

    bin->seq[0] = '0';
    bin->seq[1] = 'b';

    bin->len = arrayLen(uNumber, 2);
    bin->seq[bin->len - 1] = '\n';

    int index = bin->len - 2;

    while (uNumber > 0) {
        bin->seq[index] = (char)(uNumber%2 + '0');
        uNumber /= 2;
        index--;
    }

}

char hexbit(struct String * bin, int start, int pace) {
    int power = 1;
    int number = 0;
    for (int i = 0; i < pace; i++) {
        int n = (int)(bin->seq[start - i] - '0');
        number += n*power;
        power *= 2;
    }

    if (number >= 10) return (char)(number + 'a' - 10);
    return (char)(number + '0');
}

int strToDecimal(struct String * decimal) {
    unsigned int num = 0;
    int isNegative = decimal->seq[0] == '-';
    
    for (int i = isNegative; decimal->seq[i] != '\n'; i++) {
        num = 10*num + (unsigned int)(decimal->seq[i] - '0');
    }

    if (isNegative) return -num;
    return (int)num;
}

void decimalToStr(int number, struct String * decimal) {
    int isNegative = number < 0;
    unsigned int uNumber = isNegative ? (unsigned int)(-(number + 1)) + 1 : (unsigned int) number;
    decimal->len = isNegative ? arrayLen(uNumber,10) - 1 : arrayLen(uNumber,10) - 2; //bitsinal

    decimal->seq[decimal->len - 1] = '\n';

    int index = decimal->len - 2;

    while (uNumber != 0) {
        decimal->seq[index] = (char)((uNumber%10) + '0');
        uNumber /= 10;
        index--;
    }
    
    if (isNegative) decimal->seq[0] = '-';
}

void unsignedToStr (unsigned int number, struct String * uNumber) {
    uNumber->len = arrayLen(number, 10) - 2;

    uNumber->seq[uNumber->len - 1] = '\n';
    int index = uNumber->len - 2;

    while (number != 0) {
        uNumber->seq[index] = (char)((number%10) + '0');
        number /= 10;
        index--;
    }
}

void binToHex(struct String * hex, struct String * bin) {
    int lenbin = bin->len - 3; //tira os caracteres especiais
    hex->len = lenbin%4 == 0 ? lenbin/4 + 3 : lenbin/4 + 4;
    hex->seq[0] = '0';
    hex->seq[1] = 'x';
    hex->seq[hex->len - 1] = '\n';


    int start = bin->len - 2;
    int indexh = hex->len - 2;

    int pace;
    while (indexh > 1) {
        pace = start - 1 < 4 ? start - 1 : 4;

        hex->seq[indexh] = hexbit(bin, start, pace);
        indexh--;
        start -= pace;
    }
}

void Stringcpy(struct String * dst, struct String * origin) {
    int index = 0;

    while (1) {
        dst->seq[index] = origin->seq[index];
        if (origin->seq[index] == '\n') break;
        index++;
    }

    dst->len = origin->len;
}

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

int main(void) {
    struct String entrada;
    entrada.len = read(STDIN_FD, entrada.seq, 35);    

    struct String hex;
    struct String decimal;
    struct String sDecimal;
    struct String binary;
    struct String sHex;
    int num;
    unsigned int snum;

    if (entrada.len > 2 && entrada.seq[1] == 'x') {
        Stringcpy(&hex, &entrada); //hex
        hex.len = entrada.len;
        prepareSwapping(&hex, &sHex);
        endianSwap(&sHex); //hex swappado

        num = hexToDecimal(hex.seq); //inteiro
        decimalToStr(num, &decimal); //string do inteiro
        snum = (unsigned int)hexToDecimal(sHex.seq); //inteiro swappado
        unsignedToStr(snum, &sDecimal); //string do swappado

        decimalToBinary(num, &binary); //binario

    } else {
        Stringcpy(&decimal, &entrada);
        num = strToDecimal(&decimal); //inteiro do decimal
        decimalToBinary(num, &binary); //binario
        binToHex(&hex, &binary); //hex
        prepareSwapping(&hex, &sHex);
        endianSwap(&sHex); //hex swappado
        snum = (unsigned int)hexToDecimal(sHex.seq); //inteiro do swappado
        unsignedToStr(snum, &sDecimal); //string do swappado
    }

    write(STDOUT_FD, binary.seq, binary.len);
    write(STDOUT_FD, decimal.seq, decimal.len);
    write(STDOUT_FD, hex.seq, hex.len);
    write(STDOUT_FD, sDecimal.seq, sDecimal.len);

    return 0;
}