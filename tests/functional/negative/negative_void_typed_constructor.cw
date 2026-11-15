/*
 * tests/functional/negative/negative_void_typed_constructor.cw
 *
 * Rejects void typed constructor.
 *
 * Created: 2026-10-02
 * Author: chuck
 *
 * Changelog:
 *   2026-10-02  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * SomeClass is a class, used as a fixture by this test.
 *
 * Its methods include SomeClass.
 */
class SomeClass {
    public:
    /*
     * Handles some class for this SomeClass. Raises Exception when the call is
     * not valid (This would be the error message).
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void SomeClass() {
        raise(Exception("This would be the error message"))
    }
}
start {
    SomeClass c()
}
