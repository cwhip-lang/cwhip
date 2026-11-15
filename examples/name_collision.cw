/*
 * examples/name_collision.cw — Demonstrates name collision.
 *
 * Created: 2026-10-08
 * Author: chuck
 *
 * Changelog:
 *   2026-10-08  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace main {

    /*
     * Foo is a class, used by this example.
     *
     * Its methods include main.
     */
    class Foo {

        public:
        /*
         * Handles main for this Foo.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 main() {
            print("hello from main\n")
            return(0)
        }
    }
}

start {

    main.Foo f()
    f.main()
}
