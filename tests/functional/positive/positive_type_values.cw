/*
 * tests/functional/positive/positive_type_values.cw
 *
 * Exercises exact dynamic type names, type values, storage, and printing.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Base is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Base {
}

/*
 * Derived is a class derived from Base, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Derived : Base {
}

/*
 * Native is a class, used as a fixture by this test.
 *
 * Its methods include constructor, create.
 */
class Native {
    public:
    int64 marker
    handle saved

    /*
     * Constructs a Native and stores marker.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Native.
     */
    Native(int64 initial) {
        marker = initial
    }

    /*
     * Creates the Native state by calling the native function
     * cwhip_method_demo_handle_create.
     *
     * Takes no parameters.
     *
     * Returns handle.
     */
    handle create()
}
handle Native.create() from "cwhip_method_demo_handle_create"

namespace ns {

    /*
     * Thing is a class, used as a fixture by this test.
     *
     * It groups the data used by the surrounding program.
     */
    class Thing {
    }
}

/*
 * TypeHolder is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class TypeHolder {
    public:
    type value
}

start {
    int64 integer = 1
    bool boolean = true
    fp64 real = 2.5
    uint64 count = 5u
    strg text = "text"
    list sequence = [1]
    dict dictionary = ["key": 1]
    buffer bytes = buffer(1)
    Native native = Native(91)
    handle handleValue = native.create()
    Derived derived = Derived()
    Base base = derived
    ns.Thing qualified = ns.Thing()

    print(type(integer))
    print(type(boolean))
    print(type(real))
    print(type(count))
    print(type(text))
    print(type(sequence))
    print(type(dictionary))
    print(type(bytes))
    print(type(handleValue))
    print(type(derived))
    print(type(base))
    print(type(qualified))
    print(type(type(integer)))

    print(type(integer) == int64)
    print(type(boolean) == bool)
    print(type(real) == fp64)
    print(type(count) == uint64)
    print(type(text) == strg)
    print(type(sequence) == list)
    print(type(dictionary) == dict)
    print(type(bytes) == buffer)
    print(type(handleValue) == handle)
    print(type(derived) == Derived)
    print(derived is Base)
    print(type(base) == Derived)
    print(type(base) != Base)
    print(type(qualified) == ns.Thing)

    list dynamicValues = [integer, boolean, real, count, text, sequence,
                           dictionary, bytes, handleValue, base, null]
    print(type(dynamicValues[0]) == int64)
    print(type(dynamicValues[1]) == bool)
    print(type(dynamicValues[2]) == fp64)
    print(type(dynamicValues[3]) == uint64)
    print(type(dynamicValues[4]) == strg)
    print(type(dynamicValues[5]) == list)
    print(type(dynamicValues[6]) == dict)
    print(type(dynamicValues[7]) == buffer)
    print(type(dynamicValues[8]) == handle)
    print(type(dynamicValues[9]) == Derived)
    print(type(dynamicValues[10]))
    print(dynamicValues[10] == null)
    print(type(null) == null)

    type stored = type(base)
    print(stored)
    print(stored == type(derived))
    print(stored != Base)
    TypeHolder holder = TypeHolder()
    holder.value = ns.Thing
    print(holder.value)
    print(holder.value == type(qualified))

    type dynamicType = type(derived)
    print(dynamicType is type)
    print(type(dynamicType))
}
