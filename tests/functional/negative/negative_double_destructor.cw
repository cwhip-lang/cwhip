/*
 * tests/functional/negative/negative_double_destructor.cw
 *
 * Raises a runtime error when the same object is explicitly destroyed twice.
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
 * It groups the data used by the surrounding program.
 */
class Resource {
    public:
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
    Resource resource = Resource()
    resource.destroy()
    resource.destroy()
}
