# Verifies do-while, loop transfers, logical aliases, precedence, short-circuiting, and finally.
class Probe {
    public:
    int64 calls
    Probe() {
        calls = 0
    }
    bool touch() {
        calls = calls + 1
        return(true)
    }
    int64 read() {
        return(calls)
    }
}

start {
    int64 iterations = 0
    int64 whileTotal = 0
    while (iterations < 5) {
        iterations = iterations + 1
        if (iterations == 2) {
            continue
        }
        if (iterations == 4) {
            break
        }
        whileTotal = whileTotal + iterations
    }
    print(whileTotal)

    int64 doRuns = 0
    do {
        doRuns = doRuns + 1
    } while (false)
    print(doRuns)

    int64 doCount = 0
    do {
        doCount = doCount + 1
        if (doCount == 1) {
            continue
        }
        break
    } while (true)
    print(doCount)

    list values = [int64(1), int64(2), int64(3), int64(4)]
    int64 forTotal = 0
    for (item in values) {
        int64 value = item
        if (value == 2) {
            continue
        }
        if (value == 4) {
            break
        }
        forTotal = forTotal + value
    }
    print(forTotal)

    dict entries = ["first": int64(1), "skip": int64(2), "stop": int64(3), "last": int64(4)]
    int64 mapTotal = 0
    for (key, item in entries) {
        int64 value = item
        if (value == 2) {
            continue
        }
        if (value == 3) {
            break
        }
        mapTotal = mapTotal + value
    }
    print(mapTotal)

    int64 outer = 0
    int64 nestedTotal = 0
    while (outer < 2) {
        outer = outer + 1
        int64 inner = 0
        while (inner < 3) {
            inner = inner + 1
            break
        }
        nestedTotal = nestedTotal + inner
    }
    print(nestedTotal)

    Probe probe = Probe()
    bool andWord = false and probe.touch()
    bool andSymbol = false && probe.touch()
    bool orWord = true or probe.touch()
    bool orSymbol = true || probe.touch()
    print(andWord)
    print(andSymbol)
    print(orWord)
    print(orSymbol)
    print(probe.read())

    bool wordLogic = not (1 != 1) or 1 == 1 and 1 < 2
    bool symbolLogic = !(1 != 1) || 1 == 1 && 1 < 2
    print(wordLogic)
    print(symbolLogic)
    bool logicalPrecedence = false or true and false
    print(logicalPrecedence)
    bool comparisonPrecedence = not 0 == 2
    print(comparisonPrecedence)

    int64 cleanupCount = 0
    while (true) {
        try {
            break
        } finally {
            cleanupCount = cleanupCount + 1
        }
    }
    while (true) {
        try {
            raise(Exception("break from handler"))
        } except() {
            break
        } finally {
            cleanupCount = cleanupCount + 1
        }
    }
    int64 turns = 0
    while (turns < 2) {
        turns = turns + 1
        try {
            continue
        } finally {
            cleanupCount = cleanupCount + 1
        }
    }
    print(cleanupCount)

    int64 finalTurns = 0
    int64 finalContinues = 0
    while (finalTurns < 2) {
        finalTurns = finalTurns + 1
        try {
            print(0)
        } finally {
            finalContinues = finalContinues + 1
            continue
        }
    }
    print(finalContinues)

    int64 finalBreaks = 0
    while (true) {
        try {
            print(5)
        } finally {
            finalBreaks = finalBreaks + 1
            break
        }
    }
    print(finalBreaks)
}
