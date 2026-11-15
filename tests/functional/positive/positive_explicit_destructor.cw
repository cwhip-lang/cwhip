/*
 * tests/functional/positive/positive_explicit_destructor.cw
 *
 * Verifies an explicit destroy call invokes a class destructor and can access
 * the object state.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Resource is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Resource {
    public:
    int64 code

    /*
     * Constructs a Resource and stores code.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed Resource.
     */
    Resource(int64 value) {
        code = value
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print(code)
    }
}

start {
    Resource resource = Resource(42)
    resource.destroy()
}
