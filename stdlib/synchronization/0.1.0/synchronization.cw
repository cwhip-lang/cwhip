namespace Synchronization {
    class Runtime {
        public:
        handle mutexCreate()
        bool mutexLock(handle mutex)
        bool mutexUnlock(handle mutex)
        bool mutexRelease(handle mutex)
        handle conditionCreate()
        bool conditionWait(handle condition, handle mutex)
        bool conditionSignal(handle condition)
        bool conditionBroadcast(handle condition)
        bool conditionRelease(handle condition)
        handle semaphoreCreate(int64 initialCount)
        void semaphoreWait(handle semaphore)
        void semaphoreSignal(handle semaphore)
        void semaphoreRelease(handle semaphore)
    }

    class Mutex {
        private:
        handle _native

        public:
        Mutex() {
            _native = Runtime().mutexCreate()
        }

        handle nativeHandle() {
            return(_native)
        }

        bool lock() {
            return(Runtime().mutexLock(_native))
        }

        bool unlock() {
            return(Runtime().mutexUnlock(_native))
        }

        bool close() {
            bool released = _native == null
            if (_native != null) {
                released = Runtime().mutexRelease(_native)
            }
            if (released) {
                _native = null
            }
            return(released)
        }
    }

    class Condition {
        private:
        handle _native

        public:
        Condition() {
            _native = Runtime().conditionCreate()
        }

        bool wait(Mutex mutex) {
            return(Runtime().conditionWait(_native, mutex.nativeHandle()))
        }

        bool signal() {
            return(Runtime().conditionSignal(_native))
        }

        bool broadcast() {
            return(Runtime().conditionBroadcast(_native))
        }

        bool close() {
            bool released = _native == null
            if (_native != null) {
                released = Runtime().conditionRelease(_native)
            }
            if (released) {
                _native = null
            }
            return(released)
        }
    }

    class Semaphore {
        private:
        handle _native

        public:
        Semaphore(int64 initialCount) {
            _native = Runtime().semaphoreCreate(initialCount)
        }

        void wait() {
            Runtime().semaphoreWait(_native)
        }

        void signal() {
            Runtime().semaphoreSignal(_native)
        }

        void close() {
            if (_native != null) {
                Runtime().semaphoreRelease(_native)
                _native = null
            }
        }
    }

    handle Runtime.mutexCreate() from "cwhip_mutex_create"
    bool Runtime.mutexLock(handle mutex) from "cwhip_mutex_lock"
    bool Runtime.mutexUnlock(handle mutex) from "cwhip_mutex_unlock"
    bool Runtime.mutexRelease(handle mutex) from "cwhip_mutex_release"
    handle Runtime.conditionCreate() from "cwhip_condition_create"
    bool Runtime.conditionWait(handle condition, handle mutex) from "cwhip_condition_wait"
    bool Runtime.conditionSignal(handle condition) from "cwhip_condition_signal"
    bool Runtime.conditionBroadcast(handle condition) from "cwhip_condition_broadcast"
    bool Runtime.conditionRelease(handle condition) from "cwhip_condition_release"
    handle Runtime.semaphoreCreate(int64 initialCount) from "cwhip_semaphore_create"
    void Runtime.semaphoreWait(handle semaphore) from "cwhip_semaphore_wait"
    void Runtime.semaphoreSignal(handle semaphore) from "cwhip_semaphore_signal"
    void Runtime.semaphoreRelease(handle semaphore) from "cwhip_semaphore_release"
}
