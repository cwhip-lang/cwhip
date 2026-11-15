/*
 * tests/functional/positive/positive_internal_dynamic_values.cw
 *
 * Exercises the permitted uses of collection values without declaring any.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Holder is a class, used as a fixture by this test.
 *
 * Its methods include set, get.
 */
class Holder {
    public:
    int64 value

    /*
     * Stores input in value.
     *
     * Parameters:
     *   input — int64 input.
     *
     * Does not return a value.
     */
    void set(int64 input) {
        value = input
    }

    /*
     * Returns the stored value.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 get() {
        return(value)
    }
}

/*
 * Reader is a class, used as a fixture by this test.
 *
 * Its methods include read.
 */
class Reader {
    public:
    /*
     * Returns values[0].
     *
     * Parameters:
     *   values — list values.
     *
     * Returns int64.
     */
    int64 read(list values) {
        return(values[0])
    }
}

start {
    list values = [int64(42), "text", null]
    int64 extracted = values[0]
    Holder holder = Holder()
    holder.value = values[0]
    holder.set(values[0])
    int64 returned = Reader().read(values)

    list nested = [values[0]]
    nested.append(values[0])
    nested[0] = values[0]
    dict mapped = ["value": values[0]]
    mapped["value"] = values[0]

    print(values[0])
    print(format("formatted {}", values[0]))
    print(values[0] is int64)
    type dynamicType = type(values[0])
    print(dynamicType)
    bool isNull = values[2] == null
    print(isNull)
    print(values[0] != null)

    for (item in values) {
        print(item)
    }
}
