/*
 * tests/repro/numeric_boundaries.cw
 *
 * Curated numeric wraparound, compare, and catchable overflow cases.
 * Standalone: cwhip tests/repro/numeric_boundaries.cw -o
 * /tmp/numeric_boundaries && /tmp/numeric_boundaries Exhaustive coverage
 * remains in tests/test_numeric_execution.py.
 *
 * Created: 2026-10-30
 * Author: chuck
 *
 * Changelog:
 *   2026-10-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    print("{}\n", uint8(255) + uint8(1))
    print("{}\n", uint8(0) - uint8(1))
    print("{}\n", int8(-7) / int8(3))
    print("{}\n", int8(-7) % int8(3))
    print("{}\n", int8(-1) < uint8(0))
    print("{}\n", ~uint8(0))
    print("{}\n", int8(-2) >> 1)
    print("{}\n", int8(1) << 7)
    print("{}\n", uint16(int8(-1)))
    print("{}\n", (uint8(1) << 2 + 1))
    print("{}\n", fp64(0.1) != 0.1f64)
    print("{}\n", (1.0 / 0.0) > 0.0)
    print("{}\n", (0.0 / 0.0) != (0.0 / 0.0))
    try {
        print(int8(127) + int8(1))
    }
    except () {
        print("caught\n")
    }
    try {
        print(int8(1) / int8(0))
    }
    except () {
        print("caught\n")
    }
    try {
        print(uint8(1) << 8)
    }
    except () {
        print("caught\n")
    }
}
