/*
 * tests/functional/positive/positive_array_slice_zero_step.cw
 *
 * A constant-looking zero step remains catchable at runtime.
 *
 * Created: 2026-10-23
 * Author: chuck
 *
 * Changelog:
 *   2026-10-23  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    list values = [1, 2, 3]
    try {
        list invalid = values[::1 - 1]
    }
    except () {
        print("caught")
    }
}
