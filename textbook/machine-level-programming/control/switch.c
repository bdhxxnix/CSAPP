long switch_eg(long x, long y){
    long result = 0;
    switch (x > y) {
        case 1:
            result = x - y;
            break;
        case 0:
            result = y - x;
            break;
    }
    return result;
}