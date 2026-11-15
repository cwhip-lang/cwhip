/*
 * tests/functional/positive/positive_slice_bounds_and_steps.cw
 *
 * Covers omitted slice bounds for arrays, maps, and buffers plus list steps.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    list values = [int64(0), int64(1), int64(2), int64(3), int64(4), int64(5)]
    print(values[-1])
    int64 previous = values[-2]
    values[-2] = previous + 10
    print(values[-2])
    values[-6] = int64(7)
    print(values[0])
    try {
        int64 invalidIndex = values[-values.length - 1]
        print("unreachable")
    }
    except(Exception) as error {
        print(error.message)
    }
    try {
        int64 boundaryIndex = values[-6]
        print(boundaryIndex)
    }
    except(Exception) {
        print("negative length should be valid")
    }

    list prefix = values[:3]
    list suffix = values[3:]
    list entire = values[:]
    entire[0] = 99
    print(prefix[0])
    print(prefix[2])
    print(suffix[0])
    print(suffix[2])
    print(entire[0])
    print(values[0])

    list reverse = values[::-1]
    list everyOther = values[::2]
    list odd = values[1::2]
    list middle = values[1:5:2]
    list bounded = values[:5:2]
    list fullStep = values[::]
    print(reverse[0])
    print(reverse[5])
    print(everyOther[1])
    print(odd[2])
    print(middle[1])
    print(bounded[2])
    fullStep[1] = 88
    print(values[1])

    list descending = values[4:1:-2]
    list fromFirst = values[0::-1]
    list fromBoundary = values[6::-2]
    list negativeRange = values[-2:]
    list negativeEnd = values[:-1]
    list clamped = values[-100:100]
    list mixedNegativeStep = values[-1:-4:-1]
    print(descending[0])
    print(descending[1])
    print(fromFirst[0])
    print(fromBoundary[0])
    print(fromBoundary[2])
    print(negativeRange[0])
    print(negativeRange[1])
    print(negativeEnd[4])
    print(clamped.length)
    print(mixedNegativeStep[0])
    print(mixedNegativeStep[2])

    int64 zero = 0
    try {
        list invalid = values[1:5:zero]
        print("unreachable")
    }
    except(Exception) as error {
        print(error.message)
    }

    dict entries = ["a": 10, "b": 20, "c": 30, "d": 40]
    dict firstEntries = entries[:2]
    dict lastEntries = entries[1:]
    dict allEntries = entries[:]
    dict negativeEntries = entries[-2:]
    dict negativeRangeEntries = entries[-3:-1]
    dict clampedEntries = entries[-100:100]
    firstEntries["a"] = 99
    print(firstEntries.length)
    print(firstEntries["b"])
    print(lastEntries["b"])
    print(lastEntries["d"])
    print(allEntries["a"])
    print(entries["a"])
    print(negativeEntries["c"])
    print(negativeEntries["d"])
    print(negativeRangeEntries["b"])
    print(negativeRangeEntries["c"])
    print(clampedEntries.length)

    buffer bytes = buffer(4)
    bytes[0] = 10
    bytes[1] = 20
    bytes[2] = 30
    bytes[3] = 40
    print(bytes[-1])
    bytes[-2] = 35
    print(bytes[-2])
    bytes[-4] = 11
    print(bytes[0])
    try {
        uint64 invalidIndex = bytes[-bytes.length - 1]
        print("unreachable")
    }
    except(Exception) as error {
        print(error.message)
    }
    buffer firstBytes = bytes[:2]
    buffer lastBytes = bytes[1:]
    buffer allBytes = bytes[:]
    buffer negativeBytes = bytes[-3:-1]
    buffer clampedBytes = bytes[-100:100]
    firstBytes[0] = 99
    allBytes[1] = 88
    print(firstBytes[1])
    print(lastBytes[0])
    print(lastBytes[2])
    print(allBytes[0])
    print(bytes[0])
    print(bytes[1])
    print(negativeBytes[0])
    print(negativeBytes[1])
    print(clampedBytes.length)
}
