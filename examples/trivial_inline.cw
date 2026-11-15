/*
 * examples/trivial_inline.cw — Demonstrates trivial inline.
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
 * Its methods include setup, pstr, pnum.
 */
class Foo {

    public:
    int64 num

    /*
     * Stores 123 in num.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void setup() {
        num = 123
    }

    /*
     * Runs inline C while handling pstr.
     *
     * Parameters:
     *   s — strg input value.
     *
     * Does not return a value.
     */
    void pstr(strg s) {

        inline (strg s){
            printf("this is the %s string\n", cwhip_string_cstr(s));
        }
    }

    /*
     * Runs inline C while handling pnum.
     *
     * Parameters:
     *   val — int64 val.
     *
     * Does not return a value.
     */
    void pnum(int64 val) {

        inline(int64 val) {
            printf("this is the %lld number\n", (long long)*val);
        }
    }
}

start {

    Foo f()
    f.setup()
    f.pnum(8086)
    f.pstr("good")
}
