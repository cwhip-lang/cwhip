/*
 * tests/functional/positive/positive_system_exit_method.cw
 *
 * Checks system exit method.
 *
 * Created: 2026-11-02
 * Author: chuck
 *
 * Changelog:
 *   2026-11-02  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import system as Sys

/*
 * Quitter is a class, used as a fixture by this test.
 *
 * Its methods include quit.
 */
class Quitter {
    public:
    /*
     * Handles quit for this Quitter.
     *
     * Parameters:
     *   code — int64 code.
     *
     * Does not return a value.
     */
    void quit(int64 code) {
        print("quitting")
        Sys.System().exit(code)
        print("not reached")
    }
}

start {
    Quitter().quit(9)
    print("not reached")
}
