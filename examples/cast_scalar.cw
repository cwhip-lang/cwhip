/*
 * examples/cast_scalar.cw — Demonstrates cast scalar.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {

    int64 x = -10
    uint64 y = uint64(x)

    print(y)
}
