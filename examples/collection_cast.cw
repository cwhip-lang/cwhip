/*
 * examples/collection_cast.cw — Demonstrates collection cast.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Bar is a class, used by this example.
 *
 * Its methods include constructor, show.
 */
class Bar {

    public:
    int64 val

    /*
     * Constructs a Bar and stores val.
     *
     * Parameters:
     *   v — int64 input value.
     *
     * Returns the constructed Bar.
     */
    Bar(int64 v) {
        val = v
    }

    /*
     * Prints a value for the caller.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void show() {
        print(format("class Bar {}", val))
    }
}

/*
 * Foo is a class, used by this example.
 *
 * Its methods include constructor.
 */
class Foo {

    public:
    list flarp

    /*
     * Constructs a Foo and stores flarp, i.
     *
     * Takes no parameters.
     *
     * Returns the constructed Foo.
     */
    Foo() {
        flarp = []
        int64 i = 0
        while(i <= 10) {
            flarp.append(Bar(i))
            i += 1
        }
    }
}

start {

    Foo f()

    (f.flarp[5] as Bar).show()

}
