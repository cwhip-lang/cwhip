/*
 * stdlib/math/0.1.0/math.cw — math package implementation.
 *
 * Created: 2026-10-09
 * Author: chuck
 *
 * Changelog:
 *   2026-10-09  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Math {

    /*
     * Math is a class in this standard-library package.
     *
     * Its methods include pi, e, tau, abs, absInt, min, and 27 more.
     */
    class Math {
        public:
        /*
         * Returns the circle constant pi.
         *
         * Takes no parameters.
         *
         * Returns fp64.
         */
        fp64 pi() {
            return(3.141592653589793f64)
        }

        /*
         * Returns the base of the natural logarithm.
         *
         * Takes no parameters.
         *
         * Returns fp64.
         */
        fp64 e() {
            return(2.718281828459045f64)
        }

        /*
         * Returns the circle constant tau, which is 2 * pi.
         *
         * Takes no parameters.
         *
         * Returns fp64.
         */
        fp64 tau() {
            return(6.283185307179586f64)
        }

        /*
         * Returns the absolute value of x through the native function
         * cwhip_math_abs.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 abs(fp64 x)

        /*
         * Returns the absolute value of the integer x through the native
         * function cwhip_math_abs_int.
         *
         * Parameters:
         *   x — int64 input value.
         *
         * Returns int64.
         */
        int64 absInt(int64 x)

        /*
         * Returns the lesser of a and b through the native function
         * cwhip_math_min.
         *
         * Parameters:
         *   a — fp64 input value.
         *   b — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 min(fp64 a, fp64 b)

        /*
         * Returns the greater of a and b through the native function
         * cwhip_math_max.
         *
         * Parameters:
         *   a — fp64 input value.
         *   b — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 max(fp64 a, fp64 b)

        /*
         * Returns the lesser of the integers a and b through the native
         * function cwhip_math_min_int.
         *
         * Parameters:
         *   a — int64 input value.
         *   b — int64 input value.
         *
         * Returns int64.
         */
        int64 minInt(int64 a, int64 b)

        /*
         * Returns the greater of the integers a and b through the native
         * function cwhip_math_max_int.
         *
         * Parameters:
         *   a — int64 input value.
         *   b — int64 input value.
         *
         * Returns int64.
         */
        int64 maxInt(int64 a, int64 b)

        /*
         * Returns x limited to the inclusive range minVal..maxVal through the
         * native function cwhip_math_clamp.
         *
         * Parameters:
         *   x — fp64 input value.
         *   minVal — fp64 min val.
         *   maxVal — fp64 max val.
         *
         * Returns fp64.
         */
        fp64 clamp(fp64 x, fp64 minVal, fp64 maxVal)

        /*
         * Returns the greatest integer value not greater than x through the
         * native function cwhip_math_floor.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 floor(fp64 x)

        /*
         * Returns the least integer value not less than x through the native
         * function cwhip_math_ceil.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 ceil(fp64 x)

        /*
         * Returns x rounded to the nearest integer value through the native
         * function cwhip_math_round.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 round(fp64 x)

        /*
         * Returns x with the fractional part removed through the native
         * function cwhip_math_trunc.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 trunc(fp64 x)

        /*
         * Returns the square root of x through the native function
         * cwhip_math_sqrt.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 sqrt(fp64 x)

        /*
         * Returns the cube root of x through the native function
         * cwhip_math_cbrt.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 cbrt(fp64 x)

        /*
         * Returns base raised to the power exp through the native function
         * cwhip_math_pow.
         *
         * Parameters:
         *   base — fp64 base.
         *   exp — fp64 exp.
         *
         * Returns fp64.
         */
        fp64 pow(fp64 base, fp64 exp)

        /*
         * Returns e raised to the power x through the native function
         * cwhip_math_exp.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 exp(fp64 x)

        /*
         * Returns the natural logarithm of x through the native function
         * cwhip_math_log.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 log(fp64 x)

        /*
         * Returns the base-10 logarithm of x through the native function
         * cwhip_math_log10.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 log10(fp64 x)

        /*
         * Returns the base-2 logarithm of x through the native function
         * cwhip_math_log2.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 log2(fp64 x)

        /*
         * Returns the sine of x, with x in radians through the native function
         * cwhip_math_sin.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 sin(fp64 x)

        /*
         * Returns the cosine of x, with x in radians through the native
         * function cwhip_math_cos.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 cos(fp64 x)

        /*
         * Returns the tangent of x, with x in radians through the native
         * function cwhip_math_tan.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 tan(fp64 x)

        /*
         * Returns the arc sine of x, in radians through the native function
         * cwhip_math_asin.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 asin(fp64 x)

        /*
         * Returns the arc cosine of x, in radians through the native function
         * cwhip_math_acos.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 acos(fp64 x)

        /*
         * Returns the arc tangent of x, in radians through the native function
         * cwhip_math_atan.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 atan(fp64 x)

        /*
         * Returns the arc tangent of y / x, using the signs of both arguments
         * to choose the quadrant through the native function cwhip_math_atan2.
         *
         * Parameters:
         *   y — fp64 input value.
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 atan2(fp64 y, fp64 x)

        /*
         * Converts radians to degrees through the native function
         * cwhip_math_degrees.
         *
         * Parameters:
         *   radians — fp64 radians.
         *
         * Returns fp64.
         */
        fp64 degrees(fp64 radians)

        /*
         * Converts degrees to radians through the native function
         * cwhip_math_radians.
         *
         * Parameters:
         *   degrees — fp64 degrees.
         *
         * Returns fp64.
         */
        fp64 radians(fp64 degrees)

        /*
         * Returns the hyperbolic sine of x through the native function
         * cwhip_math_sinh.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 sinh(fp64 x)

        /*
         * Returns the hyperbolic cosine of x through the native function
         * cwhip_math_cosh.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 cosh(fp64 x)

        /*
         * Returns the hyperbolic tangent of x through the native function
         * cwhip_math_tanh.
         *
         * Parameters:
         *   x — fp64 input value.
         *
         * Returns fp64.
         */
        fp64 tanh(fp64 x)
    }

    fp64 Math.abs(fp64 x) from "cwhip_math_abs"
    int64 Math.absInt(int64 x) from "cwhip_math_abs_int"
    fp64 Math.min(fp64 a, fp64 b) from "cwhip_math_min"
    fp64 Math.max(fp64 a, fp64 b) from "cwhip_math_max"
    int64 Math.minInt(int64 a, int64 b) from "cwhip_math_min_int"
    int64 Math.maxInt(int64 a, int64 b) from "cwhip_math_max_int"
    fp64 Math.clamp(fp64 x, fp64 minVal, fp64 maxVal) from "cwhip_math_clamp"
    fp64 Math.floor(fp64 x) from "cwhip_math_floor"
    fp64 Math.ceil(fp64 x) from "cwhip_math_ceil"
    fp64 Math.round(fp64 x) from "cwhip_math_round"
    fp64 Math.trunc(fp64 x) from "cwhip_math_trunc"
    fp64 Math.sqrt(fp64 x) from "cwhip_math_sqrt"
    fp64 Math.cbrt(fp64 x) from "cwhip_math_cbrt"
    fp64 Math.pow(fp64 base, fp64 exp) from "cwhip_math_pow"
    fp64 Math.exp(fp64 x) from "cwhip_math_exp"
    fp64 Math.log(fp64 x) from "cwhip_math_log"
    fp64 Math.log10(fp64 x) from "cwhip_math_log10"
    fp64 Math.log2(fp64 x) from "cwhip_math_log2"
    fp64 Math.sin(fp64 x) from "cwhip_math_sin"
    fp64 Math.cos(fp64 x) from "cwhip_math_cos"
    fp64 Math.tan(fp64 x) from "cwhip_math_tan"
    fp64 Math.asin(fp64 x) from "cwhip_math_asin"
    fp64 Math.acos(fp64 x) from "cwhip_math_acos"
    fp64 Math.atan(fp64 x) from "cwhip_math_atan"
    fp64 Math.atan2(fp64 y, fp64 x) from "cwhip_math_atan2"
    fp64 Math.degrees(fp64 radians) from "cwhip_math_degrees"
    fp64 Math.radians(fp64 degrees) from "cwhip_math_radians"
    fp64 Math.sinh(fp64 x) from "cwhip_math_sinh"
    fp64 Math.cosh(fp64 x) from "cwhip_math_cosh"
    fp64 Math.tanh(fp64 x) from "cwhip_math_tanh"
}
