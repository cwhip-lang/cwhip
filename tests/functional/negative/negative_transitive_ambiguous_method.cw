/*
 * tests/functional/negative/negative_transitive_ambiguous_method.cw
 *
 * Rejects method lookup when virtual and non-virtual ancestor subobjects are
 * ambiguous.
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
 * Its methods include read.
 */
class Ancestor {
    public:
    /*
     * Returns 1.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(1)
    }
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
    print(diamond.read())
}
