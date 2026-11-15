/*
 * tests/functional/negative/negative_import_class_body.cw
 *
 * Rejects an import declaration nested inside a class body.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Container is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Container {
    public:
    import network as Net
}

start {}
