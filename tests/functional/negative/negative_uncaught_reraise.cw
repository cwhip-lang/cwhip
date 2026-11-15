/*
 * tests/functional/negative/negative_uncaught_reraise.cw
 *
 * Preserves the original raise location when finally runs before an exception
 * escapes.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    try {
        raise(Exception("original source"))
    }
    finally {
        print("finally before rethrow")
    }
}
