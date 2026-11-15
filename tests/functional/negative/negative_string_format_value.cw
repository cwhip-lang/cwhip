/*
 * tests/functional/negative/negative_string_format_value.cw
 *
 * Buffers are arbitrary bytes, not valid UTF-8 String values.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    buffer value = buffer(1)
    print(format("value: {}", value))
}
