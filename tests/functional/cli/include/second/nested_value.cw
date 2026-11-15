/*
 * tests/functional/cli/include/second/nested_value.cw — nested value.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * NestedValue is a class, used as a fixture by this test.
 *
 * Its methods include value.
 */
class NestedValue {
    public:
    /*
     * Returns 2.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 value() {
        return(2)
    }
}
