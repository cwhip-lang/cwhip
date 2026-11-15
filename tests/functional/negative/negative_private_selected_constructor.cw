/*
 * tests/functional/negative/negative_private_selected_constructor.cw
 *
 * Rejects private selected constructor.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * ProtectedChoice is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class ProtectedChoice {
    public:
    /*
     * Constructs a ProtectedChoice.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed ProtectedChoice.
     */
    ProtectedChoice(int64 value) {
    }

    private:
    /*
     * Constructs a ProtectedChoice.
     *
     * Parameters:
     *   value — strg value.
     *
     * Returns the constructed ProtectedChoice.
     */
    ProtectedChoice(strg value) {
    }
}

start {
    ProtectedChoice value = ProtectedChoice("private")
}
