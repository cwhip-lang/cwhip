/*
 * tests/functional/negative/negative_const_uninitialized.cw
 *
 * A const local with no initializer is still uninitialized until a store.
 *
 * Created: 2026-11-14
 * Author: Auto
 *
 * Changelog:
 *   2026-11-14  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    const int64 value
    print(value)
}
