/*
 * examples/test.cw — Demonstrates test.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {

    # Deliberately read beyond an empty buffer to demonstrate a runtime
    # diagnostic.
    buffer c = buffer(0)
    int64 ch
    ch = int64(c[0]) # << RT error: invalid buffer reference
    print(ch)
}
