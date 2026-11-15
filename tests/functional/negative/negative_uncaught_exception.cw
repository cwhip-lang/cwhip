/*
 * tests/functional/negative/negative_uncaught_exception.cw
 *
 * Produces an uncaught runtime exception when start raises without a handler.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    raise(Exception("uncaught sentinel"))
}
