/*
 * tests/functional/negative/negative_secondary_base_constructor.cw
 *
 * Rejects a multiple-inheritance constructor that omits initialization of its
 * secondary direct base.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Primary is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Primary {
    public:
    /*
     * Constructs a Primary.
     *
     * Takes no parameters.
     *
     * Returns the constructed Primary.
     */
    Primary() {
    }
}

/*
 * Secondary is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Secondary {
    public:
    /*
     * Constructs a Secondary.
     *
     * Takes no parameters.
     *
     * Returns the constructed Secondary.
     */
    Secondary() {
    }
}

/*
 * Combined is a class derived from Primary, Secondary, used as a fixture by
 * this test.
 *
 * Its methods include constructor.
 */
class Combined : Primary, Secondary {
    public:
    /*
     * Constructs a Combined.
     *
     * Takes no parameters.
     *
     * Returns the constructed Combined.
     */
    Combined() {
        super Primary()
    }
}

start {
}
