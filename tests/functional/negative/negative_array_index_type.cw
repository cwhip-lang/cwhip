/*
 * tests/functional/negative/negative_array_index_type.cw
 *
 * Rejects using a string rather than an integer as an list index.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    list values = [1, 2]
    print(values["zero"])
}
