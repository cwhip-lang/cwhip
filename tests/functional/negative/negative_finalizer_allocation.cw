/*
 * tests/functional/negative/negative_finalizer_allocation.cw
 *
 * Raises at runtime when a destructor attempts to allocate another object
 * during finalization.
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
        Resource nested = Resource()
    }
}

/*
 * Maker is a class, used as a fixture by this test.
 *
 * Its methods include make.
 */
class Maker {
    public:
    /*
     * Handles make for this Maker.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void make() {
        Resource item = Resource()
    }
}

start {
    Maker maker = Maker()
    maker.make()
    inline { cwhip_gc_collect(); }
    Resource trigger = Resource()
}
