/*
 * tests/functional/positive/positive_inherited_destructors.cw
 *
 * Exercises inherited and overridden destruction across single, multiple, and
 * diamond inheritance, including failures.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Primary is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Primary {
    public:
    int64 primaryCode

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print(primaryCode)
    }
}

/*
 * Secondary is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Secondary {
    public:
    int64 secondaryCode

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print(secondaryCode)
    }
}

/*
 * Single is a class derived from Primary, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Single : Primary {
    public:
    int64 ownCode

    /*
     * Constructs a Single and stores primaryCode, ownCode.
     *
     * Parameters:
     *   code — int64 code.
     *
     * Returns the constructed Single.
     */
    Single(int64 code) {
        super Primary()
        primaryCode = code
        ownCode = code + 1
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print(ownCode)
    }
}

/*
 * Multiple is a class derived from Primary, Secondary, used as a fixture by
 * this test.
 *
 * Its methods include constructor.
 */
class Multiple : Primary, Secondary {
    public:
    int64 ownCode

    /*
     * Constructs a Multiple and stores primaryCode, secondaryCode, ownCode.
     *
     * Parameters:
     *   code — int64 code.
     *
     * Returns the constructed Multiple.
     */
    Multiple(int64 code) {
        super Primary()
        primaryCode = code
        secondaryCode = code + 1
        ownCode = code + 2
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print(ownCode)
    }
}

/*
 * InheritedOnly is a class derived from Primary, Secondary, used as a fixture
 * by this test.
 *
 * Its methods include constructor.
 */
class InheritedOnly : Primary, Secondary {
    public:
    /*
     * Constructs a InheritedOnly and stores primaryCode, secondaryCode.
     *
     * Parameters:
     *   code — int64 code.
     *
     * Returns the constructed InheritedOnly.
     */
    InheritedOnly(int64 code) {
        super Primary()
        primaryCode = code
        secondaryCode = code + 1
    }
}

/*
 * Maker is a class, used as a fixture by this test.
 *
 * Its methods include makeUnreachable.
 */
class Maker {
    public:
    /*
     * Handles make unreachable for this Maker.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void makeUnreachable() {
        Multiple temporary = Multiple(1)
    }
}

/*
 * ThrowingBase is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class ThrowingBase {
    public:
    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("base after derived error")
        raise(Exception("base destructor failure"))
    }
}

/*
 * ThrowingDerived is a class derived from ThrowingBase, used as a fixture by
 * this test.
 *
 * Its methods include constructor.
 */
class ThrowingDerived : ThrowingBase {
    public:
    /*
     * Constructs a ThrowingDerived.
     *
     * Takes no parameters.
     *
     * Returns the constructed ThrowingDerived.
     */
    ThrowingDerived() {
        super ThrowingBase()
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        raise(Exception("derived destructor failure"))
    }
}

/*
 * Root is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Root {
    public:
    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("root subobject")
    }
}

/*
 * Left is a class derived from Root, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Left : Root {
}

/*
 * Right is a class derived from Root, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Right : Root {
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
     * Takes no parameters.
     *
     * Returns the constructed Diamond.
     */
    Diamond() {
        super Left()
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("diamond")
    }
}

start {
    Single single = Single(10)
    single.destroy()
    Primary baseView = Single(30)
    baseView.destroy()

    Maker maker = Maker()
    maker.makeUnreachable()
    inline { cwhip_gc_collect(); }
    Multiple explicit = Multiple(4)
    explicit.destroy()
    Multiple trigger = Multiple(20)

    ThrowingDerived throwing = ThrowingDerived()
    try {
        throwing.destroy()
    }
    except() as failure {
        print(failure)
    }
    try {
        throwing.destroy()
    }
    except() as repeated {
        print("caught repeated destruction")
    }

    Diamond diamond = Diamond()
    diamond.destroy()

    InheritedOnly inheritedOnly = InheritedOnly(50)
    inheritedOnly.destroy()
}
