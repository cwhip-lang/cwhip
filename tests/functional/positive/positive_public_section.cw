/*
 * tests/functional/positive/positive_public_section.cw
 *
 * Public sections expose members, and a later private member stays usable
 * inside the class.
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
 * Its methods include reveal.
 */
class Mixed {
    public:
    int64 shown

    /*
     * Returns 7.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 reveal() {
        hidden = 7
        return(hidden)
    }
    private:
    int64 hidden
}

start {
    Mixed mixed = Mixed()
    mixed.shown = 4
    print(mixed.shown)
    print(mixed.reveal())
}
