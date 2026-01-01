long absdiff(long x, long y){
    long results;
    if (x>y){
        results = x - y;
    }
    else {
        results = y - x;
    }
    return results;
}