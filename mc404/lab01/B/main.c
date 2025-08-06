extern int read(int __fd, const void *__buf, int __n);
extern void write(int __fd, const void *__buf, int __n);


int main(void) {
    char input[6];
    int read_chars = read(0, (void*) input, 6);


    int first = input[0] - '0';
    int second =  input[4] - '0';
    char value;

    switch (input[2])
    {
    case '+':
        value = first + second + '0';
        break;
    
    case '-':
        value = first - second + '0';
    
    case '*':
        value = first * second + '0';
    default:
        break;
    }

    char valueW[2];
    valueW[0] = value;
    valueW[1] = '\n';

    write(1, valueW, 2);
    return 0;
}
