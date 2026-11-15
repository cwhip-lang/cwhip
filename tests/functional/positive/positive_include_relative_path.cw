/*
 * tests/functional/positive/positive_include_relative_path.cw
 *
 * Checks an included entry file can itself resolve a nested include relative
 * to its location.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "../include_parts/relative/entry.cw"

start {
    RelativeValue value = RelativeValue()
    print(value.answer())
}
