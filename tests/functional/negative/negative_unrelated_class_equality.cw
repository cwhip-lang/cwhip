/*
 * tests/functional/negative/negative_unrelated_class_equality.cw
 *
 * Rejects unrelated class equality.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * First is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class First {
}

/*
 * Second is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Second {
}

start {
    First first = First()
    Second second = Second()
    bool same = first == second
}
