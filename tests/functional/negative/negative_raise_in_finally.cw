/*
 * tests/functional/negative/negative_raise_in_finally.cw
 *
 * Rejects raise in finally.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    try {
        print(1)
    }
    finally {
        raise()
    }
}
