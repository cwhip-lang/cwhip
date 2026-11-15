/*
 * tests/functional/negative/negative_object_type_mismatch.cw
 *
 * Rejects assigning a Counter object reference to a variable declared as int.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Counter is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Counter {
    public:
    int64 value
}

start {
    Counter counter = Counter()
    int64 invalid = counter
}
