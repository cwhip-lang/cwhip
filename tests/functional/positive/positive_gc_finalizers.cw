/*
 * tests/functional/positive/positive_gc_finalizers.cw
 *
 * Checks explicit destruction and garbage-collector finalization of
 * unreachable objects.
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

/*
 * Maker is a class, used as a fixture by this test.
 *
 * Its methods include makeExplicit, makeImplicit.
 */
class Maker {
    public:
    /*
     * Handles make explicit for this Maker.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void makeExplicit() {
        Resource item = Resource(2)
        item.destroy()
    }

    /*
     * Handles make implicit for this Maker.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void makeImplicit() {
        Resource item = Resource(1)
    }
}

start {
    Maker maker = Maker()
    maker.makeExplicit()
    maker.makeImplicit()
    inline { cwhip_gc_collect(); }
    Resource trigger = Resource(3)
    print(trigger.code)
}
