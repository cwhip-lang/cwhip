/*
 * tests/functional/positive/positive_mixed_member_visibility.cw
 *
 * Confirms an accessible public base member is selected when another
 * same-named base member is private.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * HiddenPath is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class HiddenPath {
    public:
    int64 marker
}

/*
 * VisiblePath is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class VisiblePath {
    public:
    int64 marker
}

/*
 * MixedPaths is a class derived from HiddenPath, VisiblePath, used as a
 * fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class MixedPaths : private HiddenPath, public VisiblePath {
}

start {
    MixedPaths value = MixedPaths()
    value.marker = 9
    print(value.marker)
}
