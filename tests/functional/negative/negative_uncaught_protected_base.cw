/*
 * tests/functional/negative/negative_uncaught_protected_base.cw
 *
 * Rejects uncaught protected base.
 *
 * Created: 2026-10-02
 * Author: chuck
 *
 * Changelog:
 *   2026-10-02  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Foo is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Foo {
    public:
    /*
     * Constructs a Foo.
     *
     * Takes no parameters.
     *
     * Returns the constructed Foo.
     */
    Foo() {
        raise(Exception("original base failure"))
    }
}

/*
 * Bar is a class derived from Foo, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Bar : Foo {
    public:
    /*
     * Constructs a Bar.
     *
     * Takes no parameters.
     *
     * Returns the constructed Bar.
     */
    Bar() {
        try {
            super Foo()
        }
        except() {
            print("caught locally")
            raise()
        }
        finally {
            print("local cleanup")
        }
    }
}
start {
    Bar b()
}
