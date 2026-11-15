/*
 * tests/functional/positive/positive_extern_functions.cw
 *
 * Exercises C-bound methods across scalar and reference types alongside an
 * ordinary out-of-line method.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Native is a class, used as a fixture by this test.
 *
 * Its methods include constructor, absolute, stringLength, stringIdentity,
 * identityArray, identityMap, and 2 more.
 */
class Native {
    public:
    int64 marker

    /*
     * Constructs a Native and stores marker.
     *
     * Parameters:
     *   initialMarker — int64 initial marker.
     *
     * Returns the constructed Native.
     */
    Native(int64 initialMarker) {
        marker = initialMarker
    }

    /*
     * Handles absolute for this Native by calling the native function
     * cwhip_method_demo_abs.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns int64.
     */
    int64 absolute(int64 value)

    /*
     * Handles string length for this Native by calling the native function
     * cwhip_method_demo_string_length.
     *
     * Parameters:
     *   text — strg text.
     *
     * Returns int64.
     */
    int64 stringLength(strg text)

    /*
     * Handles string identity for this Native by calling the native function
     * cwhip_method_demo_string_identity.
     *
     * Parameters:
     *   text — strg text.
     *
     * Returns strg.
     */
    strg stringIdentity(strg text)

    /*
     * Handles identity array for this Native by calling the native function
     * cwhip_method_demo_identity.
     *
     * Parameters:
     *   items — list items.
     *
     * Returns list.
     */
    list identityArray(list items)

    /*
     * Handles identity map for this Native by calling the native function
     * cwhip_method_demo_identity.
     *
     * Parameters:
     *   items — dict items.
     *
     * Returns dict.
     */
    dict identityMap(dict items)

    /*
     * Handles identity counter for this Native by calling the native function
     * cwhip_method_demo_identity.
     *
     * Parameters:
     *   value — Counter value.
     *
     * Returns Counter.
     */
    Counter identityCounter(Counter value)

    /*
     * Handles ignore for this Native by calling the native function
     * cwhip_method_demo_ignore.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Does not return a value.
     */
    void ignore(int64 value)
}

/*
 * Doubler is a class, used as a fixture by this test.
 *
 * Its methods include compute.
 */
class Doubler {
    public:
    /*
     * Handles compute for this Doubler.
     *
     * Parameters:
     *   x — int64 input value.
     *
     * Returns int64.
     */
    int64 compute(int64 x)
}

/*
 * Counter is a class, used as a fixture by this test.
 *
 * Counter is deliberately declared after Native: signatures resolve across the
 * whole source unit, including native-bound reference parameters/results.
 */
class Counter {
    public:
    int64 value

    /*
     * Constructs a Counter and stores value.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Counter.
     */
    Counter(int64 initial) {
        value = initial
    }
}

int64 Native.absolute(int64 value) from "cwhip_method_demo_abs"
int64 Native.stringLength(strg text) from "cwhip_method_demo_string_length"
strg Native.stringIdentity(strg text) from "cwhip_method_demo_string_identity"
list Native.identityArray(list items) from "cwhip_method_demo_identity"
dict Native.identityMap(dict items) from "cwhip_method_demo_identity"
Counter Native.identityCounter(Counter value) from "cwhip_method_demo_identity"
void Native.ignore(int64 value) from "cwhip_method_demo_ignore"

int64 Doubler.compute(int64 x) {
    return(x * 2)
}

start {
    # This direct same-file call stands in for the future import-based use;
    # the import/registry system is not implemented yet.
    Native native = Native(91)
    print(native.absolute(0 - 7))
    print(native.stringLength("hello"))
    print(native.stringIdentity("hello"))
    native.ignore(9)

    list numbers = [1, 2, 3]
    list same = native.identityArray(numbers)
    print(same.length)

    dict values = ["answer": 42]
    dict sameMap = native.identityMap(values)
    print(sameMap.length)

    Counter counter = Counter(42)
    Counter returned = native.identityCounter(counter)
    print(returned.value)

    print(Doubler().compute(5))
}
