/*
 * tests/functional/negative/negative_private_after_public.cw
 *
 * Rejects a member that follows private: after an earlier public section.
 *
 * Created: 2026-11-14
 * Author: Auto
 *
 * Changelog:
 *   2026-11-14  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Mixed is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Mixed {
    public:
    int64 shown
    private:
    int64 hidden
}

start {
    Mixed mixed = Mixed()
    mixed.shown = 1
    print(mixed.hidden)
}
