/*
 * tests/functional/positive/positive_start_return_finally.cw
 *
 * Checks start return finally.
 *
 * Created: 2026-11-02
 * Author: chuck
 *
 * Changelog:
 *   2026-11-02  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    try {
        print("body")
        return(5)
    }
    finally {
        print("cleanup")
    }
}
