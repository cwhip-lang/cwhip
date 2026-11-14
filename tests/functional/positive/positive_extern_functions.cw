# Exercises C-bound methods across scalar and reference types alongside an ordinary out-of-line method.
class Native {
    public:
    int64 marker

    Native(int64 initialMarker) {
        marker = initialMarker
    }

    int64 absolute(int64 value)
    int64 stringLength(strg text)
    strg stringIdentity(strg text)
    list identityArray(list items)
    dict identityMap(dict items)
    Counter identityCounter(Counter value)
    void ignore(int64 value)
}

class Doubler {
    public:
    int64 compute(int64 x)
}

# Counter is deliberately declared after Native: signatures resolve across
# the whole source unit, including native-bound reference parameters/results.
class Counter {
    public:
    int64 value

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
