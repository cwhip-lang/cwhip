/*
 * tests/functional/positive/positive_include_namespace_merge.cw
 *
 * Checks declarations from separate includes merge into the same namespace.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "../include_parts/namespace_left.cw"
include "../include_parts/namespace_right.cw"

start {
    Library.Left left = Library.Left()
    Library.Right right = Library.Right()
    print(left.answer())
    print(right.answer())
}
