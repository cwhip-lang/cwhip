/*
 * tests/functional/positive/positive_inline_no_captures.cw
 *
 * Checks a capture-free inline C block accepts ordinary C braces and executes.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    inline {
        if (1 == 1) {
            printf("inline { says } hello\n");
        }
    }
}
