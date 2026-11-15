/*
 * tests/functional/negative/negative_except_unrelated.cw
 *
 * Rejects except unrelated.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Box is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Box {
}
start {
    try {
        raise(Exception("message"))
    }
    except(Box) {
        print("not an exception")
    }
}
