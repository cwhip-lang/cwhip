/*
 * tests/functional/negative/negative_any_field_declaration.cw
 *
 * Rejects an any-typed class field.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Holder is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Holder {
    public:
    any value
}

start {
    print(1)
}
