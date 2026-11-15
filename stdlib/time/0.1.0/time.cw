/*
 * stdlib/time/0.1.0/time.cw — time package implementation.
 *
 * Created: 2026-10-09
 * Author: chuck
 *
 * Changelog:
 *   2026-10-09  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Time {

    /*
     * Clock is a class in this standard-library package.
     *
     * Its methods include epochSeconds, epochMilliseconds,
     * monotonicMilliseconds, sleepMilliseconds.
     */
    class Clock {
        public:
        /*
         * Handles epoch seconds for this Clock by calling the native function
         * cwhip_time_epoch_seconds.
         *
         * Takes no parameters.
         *
         * Returns uint64.
         */
        uint64 epochSeconds()

        /*
         * Handles epoch milliseconds for this Clock by calling the native
         * function cwhip_time_epoch_milliseconds.
         *
         * Takes no parameters.
         *
         * Returns uint64.
         */
        uint64 epochMilliseconds()

        /*
         * Handles monotonic milliseconds for this Clock by calling the native
         * function cwhip_time_monotonic_milliseconds.
         *
         * Takes no parameters.
         *
         * Returns uint64.
         */
        uint64 monotonicMilliseconds()

        /*
         * Handles sleep milliseconds for this Clock by calling the native
         * function cwhip_time_sleep_milliseconds.
         *
         * Parameters:
         *   milliseconds — uint64 milliseconds.
         *
         * Returns bool.
         */
        bool sleepMilliseconds(uint64 milliseconds)
    }

    uint64 Clock.epochSeconds() from "cwhip_time_epoch_seconds"
    uint64 Clock.epochMilliseconds() from "cwhip_time_epoch_milliseconds"
    uint64 Clock.monotonicMilliseconds() from "cwhip_time_monotonic_milliseconds"
    bool Clock.sleepMilliseconds(uint64 milliseconds) from "cwhip_time_sleep_milliseconds"
}
