/*
 * examples/err.cw — Demonstrates err.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Bar {

    /*
     * Foo is a class, used by this example.
     *
     * Its methods include constructor, open.
     */
    class Foo {

        public:
        handle fh
        strg err

        /*
         * Constructs a Foo.
         *
         * Takes no parameters.
         *
         * Returns the constructed Foo.
         */
        Foo() {
        }

        /*
         * Runs inline C while handling open.
         *
         * Parameters:
         *   fname — strg fname.
         *   mode — strg mode.
         *
         * Does not return a value.
         */
        void open(strg fname, strg mode) {

            inline(handle fh, strg err, strg fname, strg mode) {
                *fh = cwhip_file_open(NULL, *fname, *mode);
                *err = cwhip_system_last_error(NULL);
            }

            if(err.length > 0) {
                print(format("error opening \"{}\": \"{}\"", fname, err))
            }
        }
    }
}

start {

    Bar.Foo f()
    f.open("foo", "r")
}
