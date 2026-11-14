namespace Time {
    class Clock {
        public:
        uint64 epochSeconds()
        uint64 epochMilliseconds()
        uint64 monotonicMilliseconds()
        bool sleepMilliseconds(uint64 milliseconds)
    }

    uint64 Clock.epochSeconds() from "cwhip_time_epoch_seconds"
    uint64 Clock.epochMilliseconds() from "cwhip_time_epoch_milliseconds"
    uint64 Clock.monotonicMilliseconds() from "cwhip_time_monotonic_milliseconds"
    bool Clock.sleepMilliseconds(uint64 milliseconds) from "cwhip_time_sleep_milliseconds"
}
