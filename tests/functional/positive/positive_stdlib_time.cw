/*
 * tests/functional/positive/positive_stdlib_time.cw — Checks stdlib time.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import time as Time

start {
    Time.Clock clock = Time.Clock()
    uint64 before = clock.monotonicMilliseconds()
    print(clock.epochSeconds() > 1000000000u)
    print(clock.epochMilliseconds() / 1000u > clock.epochSeconds() - 2u)
    print(clock.sleepMilliseconds(5))
    uint64 after = clock.monotonicMilliseconds()
    print(after >= before + 4u)
}
