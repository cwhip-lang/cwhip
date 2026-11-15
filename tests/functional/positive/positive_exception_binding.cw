/*
 * tests/functional/positive/positive_exception_binding.cw
 *
 * Checks named exception bindings, finally execution, saved exception text,
 * and runtime errors exposed to handlers.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Box is a class, used as a fixture by this test.
 *
 * Its methods include read.
 */
class Box {
    public:
    strg note

    /*
     * Returns 1.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(1)
    }
}

start {
    Box saved = Box()
    try {
        raise(Exception("raised detail"))
    }
    except() as message {
        print(message)
    }
    finally {
        print("finally after bound exception")
    }

    try {
        raise(Exception("retained detail"))
    }
    except() as message {
        saved.note = message
    }
    print(saved.note)

    try {
        print(7 / 0)
    }
    except() as runtime {
        print(runtime)
    }

    Box missing = null
    try {
        print(missing.read())
    }
    except() as runtime {
        print(runtime)
    }

    try {
        try {
            raise(Exception("original detail"))
        }
        except() as original {
            raise(Exception("replacement detail"))
        }
    }
    except() as replacement {
        print(replacement)
    }
}
