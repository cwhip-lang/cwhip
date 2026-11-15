/*
 * tests/functional/negative/negative_transitive_ambiguous_field.cw
 *
 * Rejects field lookup when virtual and non-virtual paths produce ambiguous
 * ancestor subobjects.
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
    public:
    int64 value
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
    print(diamond.value)
}
