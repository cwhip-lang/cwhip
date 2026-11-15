/*
 * tests/functional/positive/positive_protected_base_example.cw
 *
 * Checks protected base example.
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
        raise(Exception("this is the string"))
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
            print("caught the first time")
            raise() }
    }
}
start {
    try {
        Bar b()
    }
 except() as e {
        print(e)
        print("caught the second time") }
}
