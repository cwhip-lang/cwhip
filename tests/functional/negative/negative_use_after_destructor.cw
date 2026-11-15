/*
 * tests/functional/negative/negative_use_after_destructor.cw
 *
 * Raises a runtime error when a field is read after the object has been
 * explicitly destroyed.
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
    int64 value

    /*
     * Constructs a Resource and stores value.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Resource.
     */
    Resource(int64 initial) {
        value = initial
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
    }
}

start {
    Resource resource = Resource(1)
    resource.destroy()
    print(resource.value)
}
