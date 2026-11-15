/*
 * stdlib/synchronization/0.1.0/synchronization.cw
 *
 * synchronization package implementation.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Synchronization {

    /*
     * Runtime is a class in this standard-library package.
     *
     * Its methods include mutexCreate, mutexLock, mutexUnlock, mutexRelease,
     * conditionCreate, conditionWait, and 7 more.
     */
    class Runtime {
        public:
        /*
         * Handles mutex create for this Runtime by calling the native function
         * cwhip_mutex_create.
         *
         * Takes no parameters.
         *
         * Returns handle.
         */
        handle mutexCreate()

        /*
         * Handles mutex lock for this Runtime by calling the native function
         * cwhip_mutex_lock.
         *
         * Parameters:
         *   mutex — handle mutex.
         *
         * Returns bool.
         */
        bool mutexLock(handle mutex)

        /*
         * Handles mutex unlock for this Runtime by calling the native function
         * cwhip_mutex_unlock.
         *
         * Parameters:
         *   mutex — handle mutex.
         *
         * Returns bool.
         */
        bool mutexUnlock(handle mutex)

        /*
         * Handles mutex release for this Runtime by calling the native
         * function cwhip_mutex_release.
         *
         * Parameters:
         *   mutex — handle mutex.
         *
         * Returns bool.
         */
        bool mutexRelease(handle mutex)

        /*
         * Handles condition create for this Runtime by calling the native
         * function cwhip_condition_create.
         *
         * Takes no parameters.
         *
         * Returns handle.
         */
        handle conditionCreate()

        /*
         * Handles condition wait for this Runtime by calling the native
         * function cwhip_condition_wait.
         *
         * Parameters:
         *   condition — handle condition.
         *   mutex — handle mutex.
         *
         * Returns bool.
         */
        bool conditionWait(handle condition, handle mutex)

        /*
         * Handles condition signal for this Runtime by calling the native
         * function cwhip_condition_signal.
         *
         * Parameters:
         *   condition — handle condition.
         *
         * Returns bool.
         */
        bool conditionSignal(handle condition)

        /*
         * Handles condition broadcast for this Runtime by calling the native
         * function cwhip_condition_broadcast.
         *
         * Parameters:
         *   condition — handle condition.
         *
         * Returns bool.
         */
        bool conditionBroadcast(handle condition)

        /*
         * Handles condition release for this Runtime by calling the native
         * function cwhip_condition_release.
         *
         * Parameters:
         *   condition — handle condition.
         *
         * Returns bool.
         */
        bool conditionRelease(handle condition)

        /*
         * Handles semaphore create for this Runtime by calling the native
         * function cwhip_semaphore_create.
         *
         * Parameters:
         *   initialCount — int64 initial count.
         *
         * Returns handle.
         */
        handle semaphoreCreate(int64 initialCount)

        /*
         * Handles semaphore wait for this Runtime by calling the native
         * function cwhip_semaphore_wait.
         *
         * Parameters:
         *   semaphore — handle semaphore.
         *
         * Does not return a value.
         */
        void semaphoreWait(handle semaphore)

        /*
         * Handles semaphore signal for this Runtime by calling the native
         * function cwhip_semaphore_signal.
         *
         * Parameters:
         *   semaphore — handle semaphore.
         *
         * Does not return a value.
         */
        void semaphoreSignal(handle semaphore)

        /*
         * Handles semaphore release for this Runtime by calling the native
         * function cwhip_semaphore_release.
         *
         * Parameters:
         *   semaphore — handle semaphore.
         *
         * Does not return a value.
         */
        void semaphoreRelease(handle semaphore)
    }

    /*
     * Mutex is a class in this standard-library package.
     *
     * Its methods include constructor, nativeHandle, lock, unlock, close.
     */
    class Mutex {
        private:
        handle _native

        public:
        /*
         * Constructs a Mutex and stores _native.
         *
         * Takes no parameters.
         *
         * Returns the constructed Mutex.
         */
        Mutex() {
            _native = Runtime().mutexCreate()
        }

        /*
         * Returns the stored _native.
         *
         * Takes no parameters.
         *
         * Returns handle.
         */
        handle nativeHandle() {
            return(_native)
        }

        /*
         * Returns Runtime().mutexLock(_native).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool lock() {
            return(Runtime().mutexLock(_native))
        }

        /*
         * Returns Runtime().mutexUnlock(_native).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool unlock() {
            return(Runtime().mutexUnlock(_native))
        }

        /*
         * Closes the Mutex state.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
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

    /*
     * Condition is a class in this standard-library package.
     *
     * Its methods include constructor, wait, signal, broadcast, close.
     */
    class Condition {
        private:
        handle _native

        public:
        /*
         * Constructs a Condition and stores _native.
         *
         * Takes no parameters.
         *
         * Returns the constructed Condition.
         */
        Condition() {
            _native = Runtime().conditionCreate()
        }

        /*
         * Returns Runtime().conditionWait(_native, mutex.nativeHandle()).
         *
         * Parameters:
         *   mutex — Mutex mutex.
         *
         * Returns bool.
         */
        bool wait(Mutex mutex) {
            return(Runtime().conditionWait(_native, mutex.nativeHandle()))
        }

        /*
         * Returns Runtime().conditionSignal(_native).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool signal() {
            return(Runtime().conditionSignal(_native))
        }

        /*
         * Returns Runtime().conditionBroadcast(_native).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool broadcast() {
            return(Runtime().conditionBroadcast(_native))
        }

        /*
         * Closes the Condition state.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
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

    /*
     * Semaphore is a class in this standard-library package.
     *
     * Its methods include constructor, wait, signal, close.
     */
    class Semaphore {
        private:
        handle _native

        public:
        /*
         * Constructs a Semaphore and stores _native.
         *
         * Parameters:
         *   initialCount — int64 initial count.
         *
         * Returns the constructed Semaphore.
         */
        Semaphore(int64 initialCount) {
            _native = Runtime().semaphoreCreate(initialCount)
        }

        /*
         * Handles wait for this Semaphore.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void wait() {
            Runtime().semaphoreWait(_native)
        }

        /*
         * Handles signal for this Semaphore.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void signal() {
            Runtime().semaphoreSignal(_native)
        }

        /*
         * Closes the Semaphore state.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
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
