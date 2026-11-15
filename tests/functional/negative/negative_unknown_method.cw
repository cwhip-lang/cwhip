/*
 * tests/functional/negative/negative_unknown_method.cw
 *
 * Rejects calling a method absent from the Counter class.
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
    print(counter.missing())
}
