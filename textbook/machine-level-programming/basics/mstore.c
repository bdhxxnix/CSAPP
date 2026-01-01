long mult2(long, long);

void multstore (long x, long y, long *result) {
    // the arguments are stored in registers ordered by: rdi, rsi, rdx
    // the return value is stored in rax
    long t = mult2(x, y);
    *result = t;
}
