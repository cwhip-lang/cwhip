/*
 * tests/functional/negative/negative_default_private_member.cw
 *
 * Rejects a member that has no access section when it is used outside the
 * class.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Hidden is a class, used as a fixture by this test.
 *
 * Its methods include constructor, read.
 */
class Hidden {
    int64 value
    public:
    /*
     * Constructs a Hidden.
     *
     * Takes no parameters.
     *
     * Returns the constructed Hidden.
     */
    Hidden() {
    }

    /*
     * Returns the stored value.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(value)
    }
}

start {
    Hidden hidden = Hidden()
    print(hidden.value)
}
