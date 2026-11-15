/*
 * tests/functional/positive/positive_protected_base_lifecycle.cw
 *
 * Checks protected base lifecycle.
 *
 * Created: 2026-10-02
 * Author: chuck
 *
 * Changelog:
 *   2026-10-02  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Failure is a class derived from Exception, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Failure : Exception {
    public:
    /*
     * Constructs a Failure.
     *
     * Parameters:
     *   text — strg text.
     *
     * Returns the constructed Failure.
     */
    Failure(strg text) {
        super Exception(text)
    }
}

/*
 * Other is a class derived from Exception, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Other : Exception {
    public:
    /*
     * Constructs a Other.
     *
     * Parameters:
     *   text — strg text.
     *
     * Returns the constructed Other.
     */
    Other(strg text) {
        super Exception(text)
    }
}

/*
 * Record is a class, used as a fixture by this test.
 *
 * Its methods include constructor, same.
 */
class Record {
    public:
    Exception original

    /*
     * Constructs a Record and stores original.
     *
     * Takes no parameters.
     *
     * Returns the constructed Record.
     */
    Record() {
        original = null
    }

    /*
     * Handles same for this Record by calling the native function
     * cwhip_method_demo_exception_identity.
     *
     * Parameters:
     *   left — Exception left.
     *   right — Exception right.
     *
     * Returns int64.
     */
    int64 same(Exception left, Exception right)
}
int64 Record.same(Exception left, Exception right) from "cwhip_method_demo_exception_identity"

/*
 * First is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class First {
    public:
    /*
     * Constructs a First.
     *
     * Takes no parameters.
     *
     * Returns the constructed First.
     */
    First() {
        print("first initialized")
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("INVALID first destructor")
    }
}

/*
 * Fails is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Fails {
    public:
    /*
     * Constructs a Fails.
     *
     * Takes no parameters.
     *
     * Returns the constructed Fails.
     */
    Fails() {
        raise(Failure("base failure"))
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("INVALID failed base destructor")
    }
}

/*
 * Last is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Last {
    public:
    /*
     * Constructs a Last.
     *
     * Takes no parameters.
     *
     * Returns the constructed Last.
     */
    Last() {
        print("INVALID last initialized")
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("INVALID last destructor")
    }
}

/*
 * Rethrows is a class derived from First, Fails, Last, used as a fixture by
 * this test.
 *
 * Its methods include constructor.
 */
class Rethrows : First, Fails, Last {
    public:
    /*
     * Constructs a Rethrows and stores original.
     *
     * Parameters:
     *   record — Record record.
     *   replace — bool replace.
     *
     * Returns the constructed Rethrows.
     */
    Rethrows(Record record, bool replace) {
        try {
            super First()
            super Fails()
            super Last()
        }
        except(Other) {
            raise()
        }
        except(Failure) as caught {
            record.original = caught
            print(caught.message)
            inline { cwhip_gc_collect(); }

            if (replace) {
                raise(Other("replacement"))
            }
            else {
                try {
                    raise()
                }
                except(Failure) {
                    raise()
                }
                finally {
                    print("nested cleanup")
                }
            }

        }
        finally {
            print("initializer cleanup")
        }
        print("INVALID derived continuation")
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("INVALID derived destructor")
    }
}

/*
 * Unmatched is a class derived from Fails, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Unmatched : Fails {
    public:
    /*
     * Constructs a Unmatched.
     *
     * Takes no parameters.
     *
     * Returns the constructed Unmatched.
     */
    Unmatched() {
        try {
            super Fails()
        }
        except(Other) {
            raise()
        }
        finally {
            print("unmatched cleanup")
        }
    }
}

/*
 * CleanupOnly is a class derived from Fails, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class CleanupOnly : Fails {
    public:
    /*
     * Constructs a CleanupOnly.
     *
     * Takes no parameters.
     *
     * Returns the constructed CleanupOnly.
     */
    CleanupOnly() {
        try {
            super Fails()
        }
        finally {
            print("cleanup without handler")
        }
    }
}

/*
 * Good is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Good {
    public:
    /*
     * Constructs a Good.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed Good.
     */
    Good(int64 value) {
        print(value)
    }
}

/*
 * Direct is a class derived from Good, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Direct : Good {
    public:
    /*
     * Constructs a Direct.
     *
     * Takes no parameters.
     *
     * Returns the constructed Direct.
     */
    Direct() {
        super Good(10)
        print("direct constructed")
    }
}

/*
 * Guarded is a class derived from Good, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Guarded : Good {
    public:
    /*
     * Constructs a Guarded.
     *
     * Takes no parameters.
     *
     * Returns the constructed Guarded.
     */
    Guarded() {
        try {
            super Good(20)
        }
        except() {
            raise(Exception("unexpected failure"))
        }
        finally {
            print("success cleanup")
        }
        print("protected constructed")
    }
}

/*
 * More is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class More {
    public:
    /*
     * Constructs a More.
     *
     * Takes no parameters.
     *
     * Returns the constructed More.
     */
    More() {
        print("second initialized")
    }
}

/*
 * MultiGood is a class derived from Good, More, used as a fixture by this
 * test.
 *
 * Its methods include constructor.
 */
class MultiGood : Good, More {
    public:
    /*
     * Constructs a MultiGood.
     *
     * Takes no parameters.
     *
     * Returns the constructed MultiGood.
     */
    MultiGood() {
        try {
            super Good(30)
            super More() }
        except() {
            raise()
        }
        print("multiple constructed")
    }
}

/*
 * Argument is a class, used as a fixture by this test.
 *
 * Its methods include fail.
 */
class Argument {
    public:
    /*
     * Handles fail for this Argument. Raises Exception when the call is not
     * valid (argument failure).
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 fail() {
        raise(Failure("argument failure"))
    }
}

/*
 * ArgumentFailure is a class derived from Good, used as a fixture by this
 * test.
 *
 * Its methods include constructor.
 */
class ArgumentFailure : Good {
    public:
    /*
     * Constructs a ArgumentFailure.
     *
     * Parameters:
     *   argument — Argument argument.
     *
     * Returns the constructed ArgumentFailure.
     */
    ArgumentFailure(Argument argument) {
        try {
            super Good(argument.fail())
        }
        except(Failure) {
            print("argument caught")
            raise() }
    }
}

/*
 * Driver is a class, used as a fixture by this test.
 *
 * Its methods include run.
 */
class Driver {
    public:
    /*
     * Handles run for this Driver.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void run() {
        Record record()
        try {
            Rethrows item(record, false)
        }
        except(Failure) as caught {
            print(record.same(record.original, caught))
            print(caught.message)
        }
        finally {
            print("outer cleanup")
        }
        try {
            Rethrows item(record, true)
        }
        except(Other) as caught {
            print(caught.message)
            print(record.same(record.original, caught))
        }
        try {
            Unmatched item()
        }
        except() as message {
            print(message)
        }
        try {
            CleanupOnly item()
        }
        except() as message {
            print(message)
        }
        Direct direct()
        Guarded guarded()
        MultiGood multiple()
        Argument argument()
        try {
            ArgumentFailure failed(argument)
        }
        except() as message {
            print(message)
        }
    }
}
start {
    Driver driver()
    driver.run()
    inline { cwhip_gc_collect(); }
    try {
        raise(Exception("frames still work"))
    }
    except() as message {
        print(message)
    }
}
