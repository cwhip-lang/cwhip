/*
 * tests/functional/negative/negative_transitive_virtual_base_missing_initi
 * alizer.cw
 *
 * The class being constructed directly must initialize a non-defaultable
 * virtual base even though its intermediate base supplies an initializer.
 *
 * Created: 2026-10-06
 * Author: chuck
 *
 * Changelog:
 *   2026-10-06  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * A is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class A {
    public:
    /*
     * Constructs a A.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed A.
     */
    A(int64 value) {
    }
}

/*
 * B is a class derived from A, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class B : virtual A {
    public:
    /*
     * Constructs a B.
     *
     * Takes no parameters.
     *
     * Returns the constructed B.
     */
    B() {
        super virtual A(1)
    }
}

/*
 * C is a class derived from B, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class C : B {
    public:
    /*
     * Constructs a C.
     *
     * Takes no parameters.
     *
     * Returns the constructed C.
     */
    C() {
        super B()
    }
}

start {
    C value = C()
}
