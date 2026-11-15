/*
 * tests/functional/negative/negative_transitive_ambiguous_conversion.cw
 *
 * Rejects conversion to an ancestor reached through both virtual and
 * non-virtual paths.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Ancestor is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Ancestor {
}

/*
 * VirtualPath is a class derived from Ancestor, used as a fixture by this
 * test.
 *
 * It groups the data used by the surrounding program.
 */
class VirtualPath : virtual Ancestor {
}

/*
 * OrdinaryPath is a class derived from Ancestor, used as a fixture by this
 * test.
 *
 * It groups the data used by the surrounding program.
 */
class OrdinaryPath : Ancestor {
}

/*
 * Diamond is a class derived from VirtualPath, OrdinaryPath, used as a fixture
 * by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Diamond : VirtualPath, OrdinaryPath {
}

start {
    Diamond diamond = Diamond()
    Ancestor ancestor = diamond
}
