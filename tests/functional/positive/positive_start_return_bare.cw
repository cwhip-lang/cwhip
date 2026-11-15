/*
 * tests/functional/positive/positive_start_return_bare.cw
 *
 * Checks start return bare.
 *
 * Created: 2026-11-02
 * Author: chuck
 *
 * Changelog:
 *   2026-11-02  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    print("before")
    return
    print("after")
}
