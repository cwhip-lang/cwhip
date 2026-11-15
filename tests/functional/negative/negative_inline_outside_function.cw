/*
 * tests/functional/negative/negative_inline_outside_function.cw
 *
 * Rejects an inline C block at top level rather than inside a function or
 * method.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

inline {
    printf("not allowed\n");
}

start {}
