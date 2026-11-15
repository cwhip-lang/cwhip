/*
 * examples/modules/example/0.1.0/example.cw — Demonstrates example.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Example {

    /*
     * Answer is a class, used by this example.
     *
     * Its methods include value.
     */
    class Answer {
        public:
        /*
         * Returns 42.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 value() {
            return(42)
        }
    }
}
