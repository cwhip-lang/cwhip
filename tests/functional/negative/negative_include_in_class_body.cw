/*
 * tests/functional/negative/negative_include_in_class_body.cw
 *
 * Rejects an include directive inside a class declaration.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Invalid is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Invalid {
    public:
    include "missing.cw"
}

start {}
