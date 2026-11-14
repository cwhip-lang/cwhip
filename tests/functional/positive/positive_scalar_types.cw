# Exercises distinct bool, double-backed float, and uint64 unsigned semantics.
class ScalarBox {
    public:
    bool enabled
    fp64 amount
    uint64 count
    ScalarBox(bool enabledValue, fp64 amountValue, uint64 countValue) {
        enabled = enabledValue
        amount = amountValue
        count = countValue
    }
    bool isEnabled() {
        return(enabled)
    }
    fp64 getAmount() {
        return(amount)
    }
    uint64 getCount() {
        return(count)
    }
}

start {
    bool yes = true
    bool no = false
    print(yes)
    print(no)
    bool combined = yes and not no && 3 < 4
    print(combined)
    print(yes == true)
    print(no != yes)
    if (combined) {
        print("bool condition")
    }

    int64 loops = 0
    while (loops < 3 and combined) {
        loops = loops + 1
    }
    print(loops)
    int64 doRuns = 0
    do {
        doRuns = doRuns + 1
    } while (false)
    print(doRuns)

    fp64 amount = 3.14 + 0.5
    fp64 scientific = 1.5e-3
    print(amount)
    print(scientific)
    print(amount > 3.0)

    uint64 maximum = 18446744073709551615u
    uint64 quotient = maximum / 3u
    uint64 remainder = 8u % 3u
    print(maximum)
    print(quotient)
    print(remainder)
    print(maximum > 9223372036854775808u)
    print(format("formatted {} {} {}", no, scientific, 42u))

    list values = [yes, amount, maximum]
    print(values[0])
    print(values[1])
    print(values[2])
    bool extractedBool = values[0]
    fp64 extractedFloat = values[1]
    uint64 extractedUnsigned = values[2]
    print(extractedBool)
    print(extractedFloat)
    print(extractedUnsigned)

    dict entries = ["flag": no, "amount": scientific, "count": uint64(42u)]
    bool mapBool = entries["flag"]
    fp64 mapFloat = entries["amount"]
    uint64 mapUnsigned = entries["count"]
    print(mapBool)
    print(mapFloat)
    print(mapUnsigned)

    ScalarBox box = ScalarBox(yes, amount, maximum)
    print(box.isEnabled())
    print(box.getAmount())
    print(box.getCount())
    while (doRuns < 2 and box.isEnabled() or false) {
        doRuns = doRuns + 1
    }
    print(doRuns)

    bool inlineFlag = false
    fp64 inlineAmount = 1.0
    uint64 inlineCount = 5u
    inline (bool inlineFlag, fp64 inlineAmount, uint64 inlineCount) {
        *inlineFlag = 1;
        *inlineAmount += 0.5;
        *inlineCount += 2;
    }
    print(inlineFlag)
    print(inlineAmount)
    print(inlineCount)
}
