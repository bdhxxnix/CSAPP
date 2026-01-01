#include <stdio.h>

void multstore(long x, long y, long *result);

int main() {
    long d;
    // the value of d is a random garbage value stored at that memory location: 0x7fffffffd270
    multstore(2 ,3 , &d);
    printf("Result: %ld\n", d);
    return 0;
}


long mult2(long x, long y) {
    return x * y;
}