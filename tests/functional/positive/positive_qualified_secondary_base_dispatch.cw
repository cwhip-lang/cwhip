/*
 * tests/functional/positive/positive_qualified_secondary_base_dispatch.cw
 *
 * Selects and dispatches to a method from a specifically qualified secondary
 * base.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Primary is a class, used as a fixture by this test.
 *
 * Its methods include read.
 */
class Primary {
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
 * Secondary is a class, used as a fixture by this test.
 *
 * Its methods include read.
 */
class Secondary {
    public:
    /*
     * Returns 2.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(2)
    }
}

/*
 * QualifiedCombined is a class derived from Primary, Secondary, used as a
 * fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class QualifiedCombined : Primary, Secondary {
}

start {
    QualifiedCombined combined = QualifiedCombined()
    print(combined.Secondary.read())
}
