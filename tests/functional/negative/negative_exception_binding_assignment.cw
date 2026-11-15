/*
 * tests/functional/negative/negative_exception_binding_assignment.cw
 *
 * Rejects assignment to the read-only name bound by an except clause.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    try {
        raise(Exception("read only"))
    }
    except() as message {
        message = "changed"
    }
}
