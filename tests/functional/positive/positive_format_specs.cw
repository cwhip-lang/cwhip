/*
 * tests/functional/positive/positive_format_specs.cw — Checks format specs.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Counter is a class, used as a fixture by this test.
 *
 * Its methods include next.
 */
class Counter {
    public:
    int64 calls

    /*
     * Handles next for this Counter.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 next() {
        calls += 1
        return(calls)
    }
}

/*
 * Formatter is a class, used as a fixture by this test.
 *
 * Its methods include message.
 */
class Formatter {
    public:
    /*
     * Returns format("[{:08X}]", value).
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns strg.
     */
    strg message(int64 value) {
        return(format("[{:08X}]", value))
    }
}

start {
    print("{} {} {} {:d} {:x} {:X}", 42, true, 1.25, 42u, 255, 255u)
    print("{:08X} {:08x} {:05d} {:05}", 42, -42, -12, 12u)
    print("{:x} {:X}", -9223372036854775807 - 1, 18446744073709551615u)
    print("|{:>8}|{:<8}|{:^7}|{:>2}|", "café", 42, "ok", 123)
    print("{:c}", 65)
    strg del = format("{:c}", 127u)
    print(del[0])
    strg nul = format("{:c}", 0)
    print(nul.length)
    print(nul[0])
    print("literal {malformed")
    print(format("escaped {{braces}}"))
    print(format('single {:X}', 42))
    print("{:}", false)

    Counter counter = Counter()
    print("{v:08X}/{v:d}/{v:c}", v=counter.next() + 64)
    print(counter.calls)
    print("{} {}", counter.next(), counter.next())
    print("{second}/{first}", first=counter.next(), second=counter.next())

    Formatter formatter = Formatter()
    print(formatter.message(255))
    list items = [format("item {}", 7)]
    print(items[0])
    dict mapping = [format("key {}", 1): 9]
    print(mapping["key 1"])
    strg retained = format("{} {}", formatter.message(1), counter.next())
    int64 index = 0
    while (index < 2000) {
        strg garbage = format("{:08X} {}", index, formatter.message(index))
        index += 1
    }
    print(retained)
    strg wide = format("{:1000000}", 1)
    print(wide.length)
    print(wide[0])
    print(wide[-1])
    strg zeroWide = format("{:0130X}", -42)
    print(zeroWide.length)
    print(zeroWide[0])
    print(zeroWide[1])
    print(zeroWide[-1])

    list values = [42, 255u, "text", false, 1.5]
    print("{:08X} {:x} {:>8}", values[0], values[1], values[2])
    try {
        print("NO PARTIAL OUTPUT {:c}", -1)
    }
    except() as message {
        print(message)
    }
    try {
        print("NO PARTIAL OUTPUT {:c}", 128u)
    }
    except() as message {
        print(message)
    }
    try {
        print("{:c}", values[3])
    }
    except() as message {
        print(message)
    }
    try {
        print("{:x}", values[4])
    }
    except() as message {
        print(message)
    }
    try {
        print("{:c}", 18446744073709551615u)
    }
    except() as message {
        print(message)
    }
    print("after errors")
}
