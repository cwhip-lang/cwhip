/*
 * tests/functional/positive/positive_scalar_cast_boundaries.cw
 *
 * Checks scalar cast boundaries.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Conversions is a class, used as a fixture by this test.
 *
 * Its methods include toUnsigned, toInt, floatToInt, floatToUnsigned.
 */
class Conversions {
    public:
    /*
     * Returns uint64(value).
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns uint64.
     */
    uint64 toUnsigned(int64 value) {
        return(uint64(value))
    }

    /*
     * Returns int64(value).
     *
     * Parameters:
     *   value — uint64 value.
     *
     * Returns int64.
     */
    int64 toInt(uint64 value) {
        return(int64(value))
    }

    /*
     * Returns int64(value).
     *
     * Parameters:
     *   value — fp64 value.
     *
     * Returns int64.
     */
    int64 floatToInt(fp64 value) {
        return(int64(value))
    }

    /*
     * Returns uint64(value).
     *
     * Parameters:
     *   value — fp64 value.
     *
     * Returns uint64.
     */
    uint64 floatToUnsigned(fp64 value) {
        return(uint64(value))
    }
}

start {
    int64 x = -10
    uint64 y = uint64(x)
    print(y)
    print(uint64(-10))
    Conversions conversions = Conversions()
    print(conversions.toUnsigned(-10))
    print(conversions.toUnsigned(0))
    print(conversions.toUnsigned(9223372036854775806))
    print(conversions.toUnsigned(9223372036854775807))
    print(conversions.toInt(0u))
    print(conversions.toInt(9223372036854775806u))
    print(conversions.toInt(9223372036854775807u))
    print(int64(-9223372036854775808))
    print(uint64(18446744073709551615u))
    print(fp64(9223372036854775807) == 9223372036854775808.0)
    print(fp64(18446744073709551615u) == 18446744073709551616.0)

    print(conversions.toUnsigned(-1))
    print(conversions.toUnsigned(-9223372036854775808))
    try {
        print(conversions.toInt(9223372036854775808u))
    }
    except() as error {
        print(error)
    }
    try {
        print(conversions.toInt(18446744073709551615u))
    }
    except() as error {
        print(error)
    }

    fp64 nan = 0.0 / 0.0
    fp64 infinity = 1.0 / 0.0
    fp64 negativeInfinity = -1.0 / 0.0
    fp64 positiveZero = 0.0
    fp64 negativeZero = -0.0
    fp64 subnormal = 1e-300 / 1e20
    fp64 negativeSubnormal = -subnormal
    print(bool(nan))
    print(bool(infinity))
    print(bool(negativeInfinity))
    print(bool(positiveZero))
    print(bool(negativeZero))
    print(bool(subnormal))
    print(bool(negativeSubnormal))
    print(bool(0.25))
    print(bool(-0.25))
    print(fp64(nan) != nan)
    print(fp64(infinity) == infinity)
    print(fp64(negativeInfinity) == negativeInfinity)
    print(1.0 / fp64(negativeZero) == negativeInfinity)
    print(fp64(subnormal) == subnormal)
    print(conversions.floatToInt(positiveZero))
    print(conversions.floatToInt(negativeZero))
    print(conversions.floatToUnsigned(positiveZero))
    print(conversions.floatToUnsigned(negativeZero))
    print(conversions.floatToInt(subnormal))
    print(conversions.floatToInt(negativeSubnormal))
    print(conversions.floatToUnsigned(subnormal))
    print(conversions.floatToInt(-0.25))
    print(conversions.floatToInt(-3.75))
    print(conversions.floatToUnsigned(3.75))
    print(conversions.floatToInt(-9223372036854775808.0f64))
    print(conversions.floatToInt(9223372036854774784.0f64))
    print(conversions.floatToUnsigned(18446744073709549568.0f64))

    try {
        print(conversions.floatToInt(nan))
    }
    except() as error {
        print(error)
    }
    try {
        print(conversions.floatToUnsigned(nan))
    }
    except() as error {
        print(error)
    }
    try {
        print(conversions.floatToInt(infinity))
    }
    except() as error {
        print(error)
    }
    try {
        print(conversions.floatToUnsigned(infinity))
    }
    except() as error {
        print(error)
    }
    try {
        print(conversions.floatToInt(negativeInfinity))
    }
    except() as error {
        print(error)
    }
    try {
        print(conversions.floatToUnsigned(negativeInfinity))
    }
    except() as error {
        print(error)
    }
    try {
        print(conversions.floatToUnsigned(negativeSubnormal))
    }
    except() as error {
        print(error)
    }
    try {
        print(conversions.floatToUnsigned(-0.25))
    }
    except() as error {
        print(error)
    }
    try {
        print(conversions.floatToInt(9223372036854775808.0f64))
    }
    except() as error {
        print(error)
    }
    try {
        print(conversions.floatToInt(-9223372036854777856.0f64))
    }
    except() as error {
        print(error)
    }
    try {
        print(conversions.floatToUnsigned(18446744073709551616.0f64))
    }
    except() as error {
        print(error)
    }
}
