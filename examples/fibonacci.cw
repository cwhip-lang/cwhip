# Fibonacci sequence in Cwhip

namespace Math {
    class Fib {

        # Naive recursive version (fine for small n)
        public:
        int64 compute (int64 n) {
            if (n <= 1) {
                return(n)
            }
            int64 v = compute(n - 1) + compute(n - 2)
            # print(format("{val}, ", val=v))
            return(v)
        }
    }
}

start {
    Math.Fib fib = Math.Fib()
    int64 n = 0
    print("the first 10 fibonacci numbers")
    while(n <= 10) {
        print(fib.compute(n))
        n+=1
    }
}
