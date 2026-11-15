/*
 * tests/functional/positive/positive_protected_virtual_initialization.cw
 *
 * Checks protected virtual initialization.
 *
 * Created: 2026-10-02
 * Author: chuck
 *
 * Changelog:
 *   2026-10-02  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Ancestor is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Ancestor {
    public:
    /*
     * Constructs a Ancestor.
     *
     * Takes no parameters.
     *
     * Returns the constructed Ancestor.
     */
    Ancestor() {
        print("ancestor")
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("ancestor destroyed")
    }
}

/*
 * Root is a class derived from Ancestor, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Root : virtual Ancestor {
    public:
    int64 value

    /*
     * Constructs a Root and stores value.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Root.
     */
    Root(int64 initial) {
        print("root")
        if (initial < 0) {
            raise(Exception("virtual failure"))
        }
        value = initial
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("root destroyed")
    }
}

/*
 * Left is a class derived from Root, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Left : virtual Root {
    public:
    /*
     * Constructs a Left.
     *
     * Takes no parameters.
     *
     * Returns the constructed Left.
     */
    Left() {
        print("left")
    }
}

/*
 * Right is a class derived from Root, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Right : virtual Root {
    public:
    /*
     * Constructs a Right.
     *
     * Takes no parameters.
     *
     * Returns the constructed Right.
     */
    Right() {
        print("right")
    }
}

/*
 * Diamond is a class derived from Left, Right, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Diamond : Left, Right {
    public:
    /*
     * Constructs a Diamond.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Diamond.
     */
    Diamond(int64 initial)
}
Diamond Diamond.Diamond(int64 initial) {
    try {
        super virtual Root(initial)
        super Left()
        super Right()
    }
    except() as message {
        print(message)
        raise()
    }
    finally {
        print("virtual cleanup")
    }
    print("diamond")
}

/*
 * DefaultRoot is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class DefaultRoot {
    public:
    /*
     * Constructs a DefaultRoot.
     *
     * Takes no parameters.
     *
     * Returns the constructed DefaultRoot.
     */
    DefaultRoot() {
        raise(Exception("automatic virtual failure"))
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("INVALID default root destructor")
    }
}

/*
 * DefaultLeft is a class derived from DefaultRoot, used as a fixture by this
 * test.
 *
 * Its methods include constructor.
 */
class DefaultLeft : virtual DefaultRoot {
    public:
    /*
     * Constructs a DefaultLeft.
     *
     * Takes no parameters.
     *
     * Returns the constructed DefaultLeft.
     */
    DefaultLeft() {
        print("INVALID default left continuation")
    }
}

/*
 * DefaultDiamond is a class derived from DefaultLeft, used as a fixture by
 * this test.
 *
 * Its methods include constructor.
 */
class DefaultDiamond : DefaultLeft {
    public:
    /*
     * Constructs a DefaultDiamond.
     *
     * Takes no parameters.
     *
     * Returns the constructed DefaultDiamond.
     */
    DefaultDiamond() {
        try {
            super DefaultLeft()
        }
        except() {
            print("automatic virtual caught")
            raise()
        }
    }
}
start {
    try {
        Diamond failed(-1)
    }
    except() as message {
        print(message)
    }
    try {
        DefaultDiamond failed()
    }
    except() as message {
        print(message)
    }
    Diamond good(42)
    print(good.Left.Root.value)
    print(good.Right.Root.value)
    good.destroy()
    inline { cwhip_gc_collect(); }
}
