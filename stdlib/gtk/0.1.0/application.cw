/*
 * stdlib/gtk/0.1.0/application.cw — Gtk.Application from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Application is a class in this standard-library package.
     *
     * Its methods include _create, _self, constructor, initialize, id,
     * onActivate, and 6 more.
     */
    class Application {
        private:
        /*
         * Handles create for this Application by calling the native function
         * cwhip_gtk_application_create.
         *
         * Parameters:
         *   id — String input value.
         *
         * Does not return a value.
         */
        void _create(String id)

        /*
         * Handles self for this Application by calling the native function
         * cwhip_gtk_self.
         *
         * Takes no parameters.
         *
         * Returns Application.
         */
        Application _self()
        public:
        /*
         * Constructs a Application.
         *
         * Takes no parameters.
         *
         * Returns the constructed Application.
         */
        Application() {
        }

        /*
         * Constructs a Application.
         *
         * Parameters:
         *   id — String input value.
         *
         * Returns the constructed Application.
         */
        Application(String id) {
            _create(id)
        }

        /*
         * Handles initialize for this Application by calling the native
         * function cwhip_gtk_initialize.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void initialize()

        /*
         * Handles id for this Application by calling the native function
         * cwhip_gtk_application_id.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String id()

        /*
         * Returns SignalConnection(_self(), action).
         *
         * Parameters:
         *   action — void<> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onActivate(void<> action) {
            return(SignalConnection(_self(), action))
        }

        /*
         * Handles run for this Application by calling the native function
         * cwhip_gtk_run.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void run()

        /*
         * Handles quit for this Application by calling the native function
         * cwhip_gtk_quit.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void quit()

        /*
         * Handles shutdown for this Application by calling the native function
         * cwhip_gtk_shutdown.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void shutdown()

        /*
         * Handles post for this Application by calling the native function
         * cwhip_gtk_post.
         *
         * Parameters:
         *   action — void<> action.
         *
         * Returns int64.
         */
        int64 post(void<> action)

        /*
         * Schedules the Application state by calling the native function
         * cwhip_gtk_schedule.
         *
         * Parameters:
         *   milliseconds — int64 milliseconds.
         *   action — void<> action.
         *
         * Returns int64.
         */
        int64 schedule(int64 milliseconds, void<> action)

        /*
         * Cancels the Application state by calling the native function
         * cwhip_gtk_cancel.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns bool.
         */
        bool cancel(int64 token)
    }
}
