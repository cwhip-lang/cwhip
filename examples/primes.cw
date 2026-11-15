/*
 * examples/primes.cw — Pedantic prime number filter.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    int64 limit
    int64 n
    int64 d
    int64 is_prime
    int64 rem
    int64 count

    limit = 30
    count = 0
    n = 2

    print(format("Primes up to {}:", limit))

    while (n <= limit) {
        is_prime = 1
        d = 2
        while (d * d <= n) {
            rem = n
            while (rem >= d) {
                rem = rem - d
            }
            if (rem == 0) {
                is_prime = 0
            }
            d = d + 1
        }
        if (is_prime == 1) {
            print(format("  {}", n))
            count = count + 1
        }
        n = n + 1
    }

    print(format("Found {} primes", count))
}
