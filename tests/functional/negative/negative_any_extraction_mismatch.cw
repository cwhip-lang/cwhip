/*
 * tests/functional/negative/negative_any_extraction_mismatch.cw
 *
 * Rejects extracting a string-valued list element into an int at runtime.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    // Extracting a concrete type from 'any' is runtime-checked: this list
    // slot holds a string, so extracting it into 'int' must raise instead of
    // silently reinterpreting the bits.
    list values = [1, "two", 3]
    int64 mismatched = values[1]
    print(mismatched)
}
