long arith( long x, long y, long z) {
    long t1 = x ^ y;
    long t2 = y * 48;
    long t3 = x & 0x0F0F0F0F;
    long t4 = t2 - t3 + t1 + z;
    return t4;
}


short arith3(short x, short y, short z){
    short p1 = y | z;
    short p2 = p1 >> 9;
    short p3 = ~p2;
    short p4 = y -p3;
    return p4;
}