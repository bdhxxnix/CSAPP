long switch_eg(long x, long y){
    long result = 0;
    switch (x ) {
        case 1:
            result = x - y;
            break;
        case 0:
            result = y - x;
            break;
        case 2:
            result = x * y;
            break;
        case 3:
            result = x + y;
            break;
        case 4:
            result = x / (y + 1);
            break;
        case 5:
            result = x % (y + 1);
            break;  
        case 6:
            result = x & y;
            break;
    }
    return result;
}