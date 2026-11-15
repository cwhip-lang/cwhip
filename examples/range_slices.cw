/*
 * examples/range_slices.cw — Demonstrates range slices.
 *
 * Created: 2026-10-24
 * Author: chuck
 *
 * Changelog:
 *   2026-10-24  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    list readings = [10, 20, 30, 40]
    list forward = readings[1..2]
    list backward = readings[-1..-2]
    readings[2] = 99
    print("forward: {} {}, reverse: {} {}\n",
          forward[0], forward[1], backward[
            0], backward[
            1])
    // Outer storage is copied; nested objects/collections are still shared.
    list nested = [[1]]
    list outerCopy = nested[0..0]
    list shared = nested[0]
    shared[0] = 7
    list stillShared = outerCopy[0]
    print("shared nested value: {}\n", stillShared[0])
    buffer bytes = buffer[10, 20, 30]
    buffer leading = bytes[0..1]
    buffer reversed = bytes[2..0]
    bytes[2] = uint8(99)
    print("buffer copy: {} {} {}\n", reversed[0], reversed[1], reversed[2])
    print("buffer forward: {} {}\n", leading[0], leading[1])
    print("ASCII reverse: {}, UTF-8 bytes: {}\n", "abcd"[3..1], "aéz"[1..2])
    // String offsets count bytes, not characters; partial UTF-8 is rejected.
    try {
        strg invalid = "aéz"[1..1]
    }
    except(Exception) {
        print("partial UTF-8 rejected\n")
    }
    // No clamping: both endpoints must exist, even for an empty collection.
    try {
        list invalid = readings[0..4]
    }
    except(Exception) {
        print("out-of-bounds rejected\n")
    }
    try {
        list empty = []
        list invalid = empty[0..0] }
    except(Exception) {
        print("empty slice rejected\n")
    }
}
