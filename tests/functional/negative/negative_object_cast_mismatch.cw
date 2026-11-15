/*
 * tests/functional/negative/negative_object_cast_mismatch.cw
 *
 * Rejects object cast mismatch.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Foo is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Foo {
}
start {
    list values = [42]
    Foo value = values[0] as Foo
}
