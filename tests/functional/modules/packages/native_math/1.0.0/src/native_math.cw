/*
 * tests/functional/modules/packages/native_math/1.0.0/src/native_math.cw
 *
 * native math.
 *
 * Created: 2026-10-09
 * Author: chuck
 *
 * Changelog:
 *   2026-10-09  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * NativeMath is a class, used as a fixture by this test.
 *
 * Its methods include answer.
 */
class NativeMath {
    public:
    /*
     * Handles answer for this NativeMath by calling the native function
     * cwhip_native_math_answer.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 answer()
}

int64 NativeMath.answer() from "cwhip_native_math_answer"
