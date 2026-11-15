/*
 * tests/functional/modules/packages/network/1.0.0/network.cw — network.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Network {
    namespace Http {

        /*
         * Client is a class, used as a fixture by this test.
         *
         * Its methods include constructor, get.
         */
        class Client {
            public:
            /*
             * Constructs a Client.
             *
             * Takes no parameters.
             *
             * Returns the constructed Client.
             */
            Client() {
            }

            /*
             * Returns the stored path.
             *
             * Parameters:
             *   path — strg path.
             *
             * Returns strg.
             */
            strg get(strg path) {
                return(path)
            }
        }
    }
}
