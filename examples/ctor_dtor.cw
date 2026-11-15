/*
 * examples/ctor_dtor.cw
 *
 * This example demonstrates constructors and destructors.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * FirstBase is a class, used by this example.
 *
 * Its methods include constructor, modify, init.
 */
class FirstBase {

    public:
    int64 bar
    int64 foo

    /*
     * Constructs a FirstBase and stores foo.
     *
     * Parameters:
     *   n — int64 input value.
     *
     * Returns the constructed FirstBase.
     */
    FirstBase(int64 n) {
        print("in the FirstBase constructor")
        init()
        foo = n
    }

    /*
     * Constructs a FirstBase and stores foo.
     *
     * Takes no parameters.
     *
     * Returns the constructed FirstBase.
     */
    FirstBase() {
        print("in the FirstBase constructor")
        init()
        foo = 123
    }

    /*
     * Handles modify for this FirstBase.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void modify() {
        foo += 123
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("in the FirstBase destructor")
    }

    private:
    /*
     * Stores 24 in bar.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void init() {
        bar = 24
    }
}

/*
 * SecondBase is a class, used by this example.
 *
 * Its methods include constructor.
 */
class SecondBase {

    public:
    int64 foo

    /*
     * Constructs a SecondBase and stores foo.
     *
     * Takes no parameters.
     *
     * Returns the constructed SecondBase.
     */
    SecondBase() {
        print("in the SecondBase constructor")
        foo = 42
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("in the SecondBase destructor")
    }
}

/*
 * Child is a class derived from FirstBase, SecondBase, used by this example.
 *
 * Its methods include constructor.
 */
class Child: public FirstBase, private SecondBase {

    public:
    /*
     * Constructs a Child.
     *
     * Takes no parameters.
     *
     * Returns the constructed Child.
     */
    Child() {
        super FirstBase()
        super SecondBase()
        print("\nin the Child constructor")
        print(format("first foo is {}", FirstBase.foo))
        print(format("second foo is {}", SecondBase.foo))
        print("end child constructor\n")
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("in the Child destructor")
    }
}

start {

    Child f()
    print(format("first base bar is {}", f.bar))
    f.modify()

    # correct, not private, value is chosen
    print(format("first base foo is {}\n", f.foo))

    # compiler error due to second being private to child
    # print(format("{}", f.SecondBase.foo))

    f.destroy()
}
