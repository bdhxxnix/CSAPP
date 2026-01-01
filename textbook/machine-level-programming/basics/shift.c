long shift_left4_rightn(long x, int n, int m) {
    x = x << 4;
    x = x >> n;
    return x;
}