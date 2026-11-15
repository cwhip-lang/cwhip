/*
 * tests/functional/positive/positive_string_format.cw
 *
 * Checks UTF-8 strings, string assignment, and formatted output with one or
 * multiple integer placeholders.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    strg greeting = "café\n"
    strg copy
    copy = greeting
    int64 value = 42
    print(copy)
    print(format("value: {}", value))
    print(format("sum {} {}", 20 + 1, 21))
}
