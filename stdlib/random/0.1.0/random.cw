/*
 * stdlib/random/0.1.0/random.cw — random package implementation.
 *
 * Created: 2026-10-09
 * Author: chuck
 *
 * Changelog:
 *   2026-10-09  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Random {

    /*
     * SecureRandom is a class in this standard-library package.
     *
     * Its methods include bytes, fill.
     */
    class SecureRandom {
        public:
        /*
         * Handles bytes for this SecureRandom by calling the native function
         * cwhip_random_bytes.
         *
         * Parameters:
         *   size — int64 size.
         *
         * Returns buffer.
         */
        buffer bytes(int64 size)

        /*
         * Handles fill for this SecureRandom by calling the native function
         * cwhip_random_fill.
         *
         * Parameters:
         *   target — buffer target.
         *
         * Returns bool.
         */
        bool fill(buffer target)
    }

    buffer SecureRandom.bytes(int64 size) from "cwhip_random_bytes"
    bool SecureRandom.fill(buffer target) from "cwhip_random_fill"
}
