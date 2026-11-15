/*
 * tests/functional/positive/positive_nested_returns.cw
 *
 * Checks nested returns.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Payload is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Payload {
    public:
    int64 code

    /*
     * Constructs a Payload and stores code.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed Payload.
     */
    Payload(int64 value) {
        code = value
    }
}

/*
 * ReturnProbe is a class, used as a fixture by this test.
 *
 * Its methods include makeValue, choose, fromLoop, fromFor, fromHandler,
 * rootedValue, and 3 more.
 */
class ReturnProbe {
    public:
    int64 evaluations

    /*
     * Handles make value for this ReturnProbe.
     *
     * Takes no parameters.
     *
     * Returns strg.
     */
    strg makeValue() {
        evaluations = evaluations + 1
        return("survived")
    }

    /*
     * Handles choose for this ReturnProbe.
     *
     * Parameters:
     *   first — bool first.
     *
     * Returns int64.
     */
    int64 choose(bool first) {
        if (first) {
            {
                return(10)
            }
        }
        else {
            return(20)
        }
    }

    /*
     * Handles from loop for this ReturnProbe.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 fromLoop() {
        int64 index = 0
        while (index < 3) {
            if (index == 2) {
                return(index)
            }
            index = index + 1
        }
        return(-1)
    }

    /*
     * Handles from for this ReturnProbe.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 fromFor() {
        for (item in [int64(1), int64(2)]) {
            int64 value = item
            if (value == 2) {
                return(value)
            }
        }
        return(-1)
    }

    /*
     * Handles from handler for this ReturnProbe. Raises Exception when the
     * call is not valid (go).
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 fromHandler() {
        try {
            try {
                raise(Exception("go"))
            }
            except(Exception) {
                return(7)
            }
            finally {
                print("inner finally")
            }
        }
        finally {
            print("outer finally")
        }
    }

    /*
     * Handles rooted value for this ReturnProbe.
     *
     * Parameters:
     *   self — ReturnProbe self.
     *
     * Returns strg.
     */
    strg rootedValue(ReturnProbe self) {
        try {
            return(self.makeValue())
        }
        finally {
            int64 count = 0
            while (count < 180) {
                strg temporary = "temporary"
                count = count + 1
            }
            print(evaluations)
        }
    }

    /*
     * Handles rooted object for this ReturnProbe.
     *
     * Takes no parameters.
     *
     * Returns Payload.
     */
    Payload rootedObject() {
        try {
            return(Payload(99))
        }
        finally {
            int64 count = 0
            while (count < 180) {
                Payload temporary = Payload(count)
                count = count + 1
            }
        }
    }

    /*
     * Handles replaced by exception for this ReturnProbe. Raises Exception
     * when the call is not valid (replacement).
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 replacedByException() {
        try {
            return(8)
        }
        finally {
            raise(Exception("replacement"))
        }
    }

    /*
     * Handles early exit for this ReturnProbe.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void earlyExit() {
        do {
            try {
                return
            }
            finally {
                print("void finally")
            }
        } while (false)
        print("unreachable")
    }
}

start {
    ReturnProbe probe = ReturnProbe()
    print(probe.choose(true))
    print(probe.choose(false))
    print(probe.fromLoop())
    print(probe.fromFor())
    print(probe.fromHandler())
    print(probe.rootedValue(probe))
    print(probe.rootedObject().code)
    try {
        print(probe.replacedByException())
    }
    except(Exception) as caught {
        print(caught.message)
    }
    probe.earlyExit()
}
