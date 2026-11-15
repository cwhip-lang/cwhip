/*
 * tests/functional/positive/positive_scalar_casts.cw
 *
 * All sixteen ordered scalar pairs, including identities.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Scalars is a class, used as a fixture by this test.
 *
 * Its methods include flag, signedValue, unsignedValue, fraction, fromBool.
 */
class Scalars {
    public:
    /*
     * Returns the stored true.
     *
     * Takes no parameters.
     *
     * Returns bool.
     */
    bool flag() {
        return(true)
    }

    /*
     * Returns -7.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 signedValue() {
        return(-7)
    }

    /*
     * Returns 12u.
     *
     * Takes no parameters.
     *
     * Returns uint64.
     */
    uint64 unsignedValue() {
        return(12u)
    }

    /*
     * Returns 3.75.
     *
     * Takes no parameters.
     *
     * Returns fp64.
     */
    fp64 fraction() {
        return(3.75)
    }

    /*
     * Returns int64(value).
     *
     * Parameters:
     *   value — bool value.
     *
     * Returns int64.
     */
    int64 fromBool(bool value) {
        return(int64(value))
    }
}

start {
    int64 i = 7
    uint64 u = 12
    fp64 f = 3.75

    print(fp64(i))
    print(fp64(u))
    print(int64(f))
    print(uint64(f))
    print(int64(-3.99))

    fp64 sum = fp64(i) + f
    print(sum)

    bool b = true
    print(bool(b))
    print(int64(b))
    print(uint64(b))
    print(fp64(b))
    print(bool(i))
    print(int64(i))
    print(uint64(i))
    print(bool(u))
    print(int64(u))
    print(uint64(u))
    print(bool(f))
    print(fp64(f))

    print(int64(false))
    print(uint64(false))
    print(fp64(false))
    print(bool(0))
    print(bool(0u))
    print(bool(-1))
    print(bool(-9223372036854775808))
    print(bool(18446744073709551615u))
    print(int64(true))
    print(uint64(true))
    print(fp64(true))

    Scalars values = Scalars()
    print(int64(values.flag()))
    print(bool(values.signedValue()))
    print(int64(values.unsignedValue()))
    print(uint64(values.fraction()))
    i = int64(values.fraction())
    u = uint64(i)
    f = fp64(u)
    b = bool(f)
    print(i)
    print(u)
    print(f)
    print(b)
    print(values.fromBool(bool(2)))

    # Casts consume null flags, including identity casts.
    bool nullBool = null
    int64 nullInt = null
    uint64 nullUnsigned = null
    fp64 nullFloat = null
    print(bool(nullBool))
    print(int64(nullBool))
    print(uint64(nullBool))
    print(fp64(nullBool))
    print(bool(nullInt))
    print(int64(nullInt))
    print(uint64(nullInt))
    print(fp64(nullInt))
    print(bool(nullUnsigned))
    print(int64(nullUnsigned))
    print(uint64(nullUnsigned))
    print(fp64(nullUnsigned))
    print(bool(nullFloat))
    print(int64(nullFloat))
    print(uint64(nullFloat))
    print(fp64(nullFloat))
    nullBool = bool(nullBool)
    nullInt = int64(nullInt)
    nullUnsigned = uint64(nullUnsigned)
    nullFloat = fp64(nullFloat)
    print(nullBool == null)
    print(nullInt == null)
    print(nullUnsigned == null)
    print(nullFloat == null)
    print(type(bool))
}
