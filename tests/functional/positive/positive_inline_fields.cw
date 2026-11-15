/*
 * tests/functional/positive/positive_inline_fields.cw — Checks inline fields.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Primary is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Primary {
    protected:
    int64 primary
    public:
    /*
     * Constructs a Primary and stores primary.
     *
     * Takes no parameters.
     *
     * Returns the constructed Primary.
     */
    Primary() {
        primary = 10
    }
}

/*
 * Secondary is a class, used as a fixture by this test.
 *
 * Its methods include constructor, updateSecondary.
 */
class Secondary {
    public:
    int64 secondary

    /*
     * Constructs a Secondary and stores secondary.
     *
     * Takes no parameters.
     *
     * Returns the constructed Secondary.
     */
    Secondary() {
        secondary = 20
    }

    /*
     * Runs inline C while handling update secondary.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void updateSecondary() {
        inline (int64 secondary) { *secondary += 1; }
    }
}

/*
 * Fields is a class derived from Primary, Secondary, used as a fixture by this
 * test.
 *
 * Its methods include constructor, update, read, shadowLocal, store.
 */
class Fields : Primary, Secondary {
    private:
    int64 own
    strg text
    buffer bytes
    Root saved
    public:
    /*
     * Constructs a Fields and stores own, text, bytes.
     *
     * Takes no parameters.
     *
     * Returns the constructed Fields.
     */
    Fields() {
        super Primary()
        super Secondary()
        inline (int64 own, strg text, buffer bytes) {
            *own = 30;
            *text = cwhip_system_arg(NULL, 0);
            *bytes = cwhip_random_bytes(NULL, 2);
        }
    }

    /*
     * Runs inline C while handling update.
     *
     * Parameters:
     *   own — int64 own.
     *
     * Does not return a value.
     */
    void update(int64 own) {
        inline (int64 own) { *own += 2; }
        print(own)
        inline (int64 .own, int64 primary, int64 Secondary.secondary) {
            *own += 3;
            *primary += 4;
            *secondary += 5;
        }
        print(text.length > 0)
        print(bytes.length)
        print(Primary.primary)
        print(Secondary.secondary)
    }

    /*
     * Returns the stored own.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(own)
    }

    /*
     * Runs inline C while handling shadow local.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void shadowLocal() {
        int64 own = 200
        inline (int64 own) { *own += 2; }
        print(own)
    }

    /*
     * Runs inline C while handling store.
     *
     * Parameters:
     *   input — Root input.
     *
     * Does not return a value.
     */
    void store(Root input) {
        inline (Root saved, Root input) { *saved = *input; }
        buffer trigger = buffer(1)
        print(saved.shared)
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        inline (int64 own) { *own += 7; }
        print(own)
    }
}

/*
 * Root is a class, used as a fixture by this test.
 *
 * Its methods include constructor, updateRoot.
 */
class Root {
    public:
    int64 shared
    list values

    /*
     * Constructs a Root and stores shared.
     *
     * Takes no parameters.
     *
     * Returns the constructed Root.
     */
    Root() {
        shared = 40
    }

    /*
     * Runs inline C while handling update root.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void updateRoot() {
        inline (int64 shared) { *shared += 1; }
    }
}

/*
 * Left is a class derived from Root, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Left : virtual Root {
}

/*
 * Right is a class derived from Root, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Right : virtual Root {
}

/*
 * Diamond is a class derived from Left, Right, used as a fixture by this test.
 *
 * Its methods include update.
 */
class Diamond : Left, Right {
    public:
    /*
     * Runs inline C while handling update.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void update() {
        inline (int64 shared) { *shared += 2; }
        inline (int64 Right.Root.shared) { *shared += 3; }
        inline (list Right.Root.values) { *values = cwhip_system_argv(NULL); }
    }
}

/*
 * RepeatedRoot is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class RepeatedRoot {
    public: int64 value
}

/*
 * First is a class derived from RepeatedRoot, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class First : RepeatedRoot {
}

/*
 * Second is a class derived from RepeatedRoot, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Second : RepeatedRoot {
}

/*
 * Repeated is a class derived from First, Second, used as a fixture by this
 * test.
 *
 * Its methods include update.
 */
class Repeated : First, Second {
    public:
    /*
     * Runs inline C while handling update.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void update() {
        inline (int64 First.RepeatedRoot.value) { *value = 51; }
        inline (int64 Second.RepeatedRoot.value) { *value = 61; }
    }
}

start {
    Fields fields = Fields()
    fields.update(100)
    fields.shadowLocal()
    fields.Secondary.updateSecondary()
    print(fields.Secondary.secondary)
    print(fields.read())
    fields.destroy()
    Diamond diamond = Diamond()
    diamond.update()
    diamond.Right.Root.updateRoot()
    print(diamond.Left.Root.shared)
    print(diamond.Right.Root.shared)
    print(diamond.Left.Root.values.length > 0)
    fields = Fields()
    fields.store(diamond)
    fields.destroy()
    Repeated repeated = Repeated()
    repeated.update()
    print(repeated.First.RepeatedRoot.value)
    print(repeated.Second.RepeatedRoot.value)
}
