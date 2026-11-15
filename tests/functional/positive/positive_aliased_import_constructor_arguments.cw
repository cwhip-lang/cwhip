/*
 * tests/functional/positive/positive_aliased_import_constructor_arguments.
 * cw
 *
 * Checks aliased import constructor arguments.
 *
 * Created: 2026-10-12
 * Author: chuck
 *
 * Changelog:
 *   2026-10-12  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import system as sys

/*
 * Box is a class, used as a fixture by this test.
 *
 * Its methods include constructor, label, set, rebuild.
 */
class Box {
    public:
    String value

    /*
     * Constructs a Box and stores value.
     *
     * Parameters:
     *   text — String text.
     *
     * Returns the constructed Box.
     */
    Box(String text) {
        value = text
    }

    /*
     * Constructs a Box and stores value.
     *
     * Parameters:
     *   number — int64 number.
     *
     * Returns the constructed Box.
     */
    Box(int64 number) {
        value = "int"
    }

    /*
     * Constructs a Box and stores value.
     *
     * Parameters:
     *   flag — bool flag.
     *
     * Returns the constructed Box.
     */
    Box(bool flag) {
        value = "bool"
    }

    /*
     * Returns the stored value.
     *
     * Takes no parameters.
     *
     * Returns String.
     */
    String label() {
        return(value)
    }

    /*
     * Stores text in value.
     *
     * Parameters:
     *   text — String text.
     *
     * Does not return a value.
     */
    void set(String text) {
        value = text
    }

    /*
     * Stores "int" in value.
     *
     * Parameters:
     *   number — int64 number.
     *
     * Does not return a value.
     */
    void set(int64 number) {
        value = "int"
    }

    /*
     * Returns Box(sys.FileSystem().basename("/m/method.txt")).
     *
     * Takes no parameters.
     *
     * Returns Box.
     */
    Box rebuild() {
        return(Box(sys.FileSystem().basename("/m/method.txt")))
    }
}

/*
 * Pair is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Pair {
    public:
    Box inner

    /*
     * Constructs a Pair and stores inner.
     *
     * Parameters:
     *   box — Box box.
     *
     * Returns the constructed Pair.
     */
    Pair(Box box) {
        inner = box
    }
}

/*
 * Derived is a class derived from Box, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Derived : Box {
    public:
    /*
     * Constructs a Derived.
     *
     * Takes no parameters.
     *
     * Returns the constructed Derived.
     */
    Derived() {
        super Box(sys.FileSystem().basename("/d/derived.txt"))
    }
}

/*
 * AliasError is a class derived from Exception, used as a fixture by this
 * test.
 *
 * Its methods include constructor.
 */
class AliasError : Exception {
    public:
    /*
     * Constructs a AliasError.
     *
     * Takes no parameters.
     *
     * Returns the constructed AliasError.
     */
    AliasError() {
        super Exception(sys.FileSystem().basename("/e/base.txt"))
    }
}

start {
    bool opened = false
    try {
        sys.File missing("/definitely/not/a/cwhip/dir/file.txt", "r")
        opened = missing.isOpen()
    }
    except(Exception) {
        opened = false
    }
    print(opened)

    try {
        raise(Exception(sys.System().lastError()))
    }
    except() as message {
        print(message.length > 0)
    }

    Exception direct = Exception(sys.FileSystem().basename("/x/direct.txt"))
    print(direct.message)

    Box box = Box(sys.FileSystem().basename("/b/box.txt"))
    print(box.label())

    Box declared(sys.FileSystem().extension("/b/declared.cw"))
    print(declared.label())

    Pair pair = Pair(Box(sys.FileSystem().basename("/p/nested.txt")))
    print(pair.inner.label())

    box.set(sys.FileSystem().basename("/s/overload.txt"))
    print(box.label())

    print(box.rebuild().label())
    print(Derived().label())
    print(AliasError().message)

    list files = [sys.FileSystem()]
    Box typed = Box(files[0] is sys.FileSystem)
    print(typed.label())
}
