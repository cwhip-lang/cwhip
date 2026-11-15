/*
 * tests/functional/positive/positive_intermediate_virtual_base_initializer
 * s.cw
 *
 * A class can initialize its virtual base directly; when used as a base, its
 * initializer and argument expression are skipped.
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
    int64 value

    /*
     * Constructs a A and stores value.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed A.
     */
    A(int64 initial) {
        value = initial
        print(format("A:{}", initial))
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print(format("A-{}", value))
    }
}

/*
 * B is a class derived from A, used as a fixture by this test.
 *
 * Its methods include initializerArgument, constructor.
 */
class B : virtual A {
    public:
    /*
     * Handles initializer argument for this B.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 initializerArgument() {
        print("B initializer argument")
        return(1)
    }

    /*
     * Constructs a B.
     *
     * Takes no parameters.
     *
     * Returns the constructed B.
     */
    B() {
        try {
            super virtual A(initializerArgument())
        }
        except() {
            raise()
        }
        print("B")
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("B-")
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
        super virtual A(2)
        super B()
        print("C")
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("C-")
    }
}

start {
    B direct = B()
    print(direct.A.value)
    C derived = C()
    print(derived.B.A.value)
    direct.destroy()
    derived.destroy()
}
