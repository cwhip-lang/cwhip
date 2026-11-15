/*
 * tests/functional/positive/positive_const_locals.cw
 *
 * A const local accepts one value. A later store raises a catchable exception.
 *
 * Created: 2026-11-14
 * Author: Auto
 *
 * Changelog:
 *   2026-11-14  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Box is a class, used as a fixture by this test.
 *
 * Its methods include constructor, read, write, step.
 */
class Box {
    public:
    int64 value

    /*
     * Constructs a Box and stores seed, value.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Box.
     */
    Box(int64 initial) {
        const int64 seed = initial
        value = seed
    }

    /*
     * Returns the stored value.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(value)
    }

    /*
     * Stores next in value.
     *
     * Parameters:
     *   next — int64 next.
     *
     * Does not return a value.
     */
    void write(int64 next) {
        value = next
    }

    /*
     * Handles step for this Box.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 step() {
        const int64 amount = 1
        return(value + amount)
    }
}

start {
    const int64 fixed = 1
    try {
        fixed = 2
        print("missed-fixed")
    }
    except() as error {
        print(error)
    }
    print(fixed)

    const int64 later
    later = 3
    print(later)
    try {
        later = 4
        print("missed-later")
    }
    except() as error {
        print("later")
    }
    print(later)

    const int64 branched
    if (true) {
        branched = 5
    }
    try {
        branched = 6
        print("missed-branch")
    }
    except() as error {
        print("branch")
    }

    const int64 open
    if (false) {
        open = 7
    }
    open = 8
    print(open)
    try {
        open = 9
        print("missed-open")
    }
    except() as error {
        print("open")
    }
    print(open)

    const int64 count = 10
    try {
        count += 1
        print("missed-count")
    }
    except() as error {
        print("count")
    }
    print(count)

    const int64 grown
    grown = 11
    try {
        grown += 1
        print("missed-grown")
    }
    except() as error {
        print("grown")
    }
    print(grown)

    const Box item(12)
    item.write(13)
    print(item.read())
    print(item.step())
    try {
        item = Box(14)
        print("missed-item")
    }
    except() as error {
        print("item")
    }
    print(item.read())

    const list numbers = [1]
    numbers[0] = 15
    print(numbers[0])
    try {
        numbers = [16]
        print("missed-list")
    }
    except() as error {
        print("list")
    }
    print(numbers[0])

    int64 plain = 17
    plain = 18
    plain += 1
    print(plain)

    CONST int64 shouted = 19
    print(shouted)
}
