# Exercises the universal-null model (confirmed): null is a single value
# assignable to every type, including scalars, with no flow-sensitive
# null analysis. Printing a null value of any type prints "(null)";
# member access on a null reference raises an exception; every other use
# of a null scalar decays to that type's zero value.
class Holder {
    public:
    int64 value

    Holder(int64 initialValue) {
        value = initialValue
    }
}

start {
    int64 declaredNullInt = null
    print(declaredNullInt)

    int64 reassigned = 12
    reassigned = declaredNullInt
    print(reassigned)
    print(reassigned == null)
    print(reassigned != null)

    uint64 nullUnsigned = null
    print(nullUnsigned)

    fp64 nullFloat = null
    print(nullFloat)

    bool nullBool = null
    print(nullBool)

    strg nullString = null
    print(nullString)
    print(nullString == null)

    list nullArray = null
    print(nullArray == null)

    dict nullMap = null
    print(nullMap == null)

    Holder missing = null
    print(missing == null)
    try {
        print(missing.value)
    } except() {
        print("caught")
    }

    # A null scalar used outside declare/reassign/print/null-comparison
    # (a constructor argument, arithmetic) decays deterministically to the
    # type's zero value rather than crashing or corrupting state.
    Holder fromNull = Holder(declaredNullInt)
    print(fromNull.value)
    print(declaredNullInt + 5)
}
