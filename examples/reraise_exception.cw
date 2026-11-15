/*
 * examples/reraise_exception.cw
 *
 * Re-raise an exception after it was already caught.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Foo is a class, used by this example.
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
        raise(Exception("this is the string"))
    }
}

/*
 * Bar is a class derived from Foo, used by this example.
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
            print("caught the first time")
            raise()
        }
    }
}

start {

    try {
        Bar b()
    }
    except() as e {
        print(e)
        print("caught the second time")
    }
}
