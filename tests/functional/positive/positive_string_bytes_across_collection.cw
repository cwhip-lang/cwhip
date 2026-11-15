/*
 * tests/functional/positive/positive_string_bytes_across_collection.cw
 *
 * A finalizer rewrites a live string during a range copy, trim, and split.
 * Each result must be the bytes observed at the start of that call.
 *
 * Created: 2026-10-28
 * Author: chuck
 *
 * Changelog:
 *   2026-10-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Box is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Box {
    public:
    strg text

    /*
     * Constructs a Box and stores text.
     *
     * Parameters:
     *   value — strg value.
     *
     * Returns the constructed Box.
     */
    Box(strg value) {
        text = value
    }
}

/*
 * Mutator is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Mutator {
    public:
    Box box

    /*
     * Constructs a Mutator and stores box.
     *
     * Parameters:
     *   target — Box target.
     *
     * Returns the constructed Mutator.
     */
    Mutator(Box target) {
        box = target
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        strg text = box.text
        text.clear()
        inline (strg text) {
            const char bytes[] = {'Z', 'Z', 'Z', 'Z', 'Z', 'Z'};
            cwhip_string_append_bytes(*text, bytes, 6);
        }
    }
}

/*
 * Maker is a class, used as a fixture by this test.
 *
 * Its methods include abandon.
 */
class Maker {
    public:
    /*
     * Handles abandon for this Maker.
     *
     * Parameters:
     *   box — Box box.
     *
     * Does not return a value.
     */
    void abandon(Box box) {
        Mutator gone = Mutator(box)
    }
}

start {
    Maker maker = Maker()
    Box sliceBox = Box("abcdef")
    range<int64> bounds = 1..3
    maker.abandon(sliceBox)
    strg sliced = sliceBox.text[bounds]
    print(sliced)
    print("\n")
    print(sliceBox.text)
    print("\n")

    Box trimBox = Box("  ab  ")
    maker.abandon(trimBox)
    strg trimmed = trimBox.text.trim()
    print(trimmed)
    print("\n")
    print(trimBox.text)
    print("\n")

    Box splitBox = Box("a,b,c")
    strg comma = ","
    maker.abandon(splitBox)
    list parts = splitBox.text.split(comma)
    strg first = parts[0]
    strg second = parts[1]
    strg third = parts[2]
    print(first)
    print("\n")
    print(second)
    print("\n")
    print(third)
    print("\n")
    print(splitBox.text)
    print("\n")
}
