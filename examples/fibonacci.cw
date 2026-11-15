/*
 * examples/fibonacci.cw — Fibonacci sequence in Cwhip.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Math {

    /*
     * Fib is a class, used by this example.
     *
     * Its methods include compute.
     */
    class Fib {

        # Naive recursive version (fine for small n)
        public:
        /*
         * Handles compute for this Fib.
         *
         * Parameters:
         *   n — int64 input value.
         *
         * Returns int64.
         */
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
