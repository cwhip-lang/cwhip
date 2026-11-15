/*
 * tests/functional/negative/negative_ambiguous_inherited_field.cw
 *
 * Rejects an unqualified field lookup when two non-virtual base subobjects
 * provide that field.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Root is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Root {
    public:
    int64 value
}

/*
 * Left is a class derived from Root, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Left : Root {
}

/*
 * Right is a class derived from Root, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Right : Root {
}

/*
 * Diamond is a class derived from Left, Right, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Diamond : Left, Right {
}

start {
    Diamond diamond = Diamond()
    print(diamond.value)
}
