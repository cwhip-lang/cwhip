/*
 * tests/functional/positive/positive_sequence_operations.cw
 *
 * Shared sequence operations: String byte indexing and assignment, inclusive
 * removal, list insert/remove/clear with buffer and handle elements, buffer
 * insert/remove, and dict clear.
 *
 * Created: 2026-10-28
 * Author: chuck
 *
 * Changelog:
 *   2026-10-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    strg text = "abcd"
    print(text[0])
    text[0] = 65
    print(text)
    print(text[3..1])
    text.remove(3..1)
    print(text)
    try {
        text[0] = 0xC3
    }
    except() {
        print("high byte")
    }
    strg accented = "aéz"
    try {
        accented[1] = 65
    }
    except() {
        print("split")
    }
    try {
        uint8 missing = text[4]
    }
    except() {
        print("index bounds")
    }
    try {
        strg outside = text[0..4]
    }
    except() {
        print("range bounds")
    }

    list values = [1]
    buffer bytes = buffer[9]
    handle native = null
    values.append(bytes)
    values.append(native)
    print(values.length)
    values.insert(1, "mid")
    print(values[1] as strg)
    values.remove(3..2)
    print(values.length)
    print(values[0])
    print(values[1] as strg)
    values.clear()
    print(values.length)

    buffer data = buffer[1, 2, 3]
    data.insert(1, 9)
    print(data[1])
    data.remove(1..0)
    print(data.length)
    print(data[0])

    dict options = ["a": 1, "b": 2]
    options.clear()
    print(options.length)
}
