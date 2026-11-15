/*
 * tests/functional/positive/positive_named_string_format.cw
 *
 * Checks named formatting, escaped braces, supported values, and single
 * evaluation.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Counter is a class, used as a fixture by this test.
 *
 * Its methods include constructor, next.
 */
class Counter {
    public:
    int64 calls

    /*
     * Constructs a Counter and stores calls.
     *
     * Takes no parameters.
     *
     * Returns the constructed Counter.
     */
    Counter() {
        calls = 0
    }

    /*
     * Handles next for this Counter.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 next() {
        calls += 1
        return(calls)
    }
}

/*
 * Mutator is a class, used as a fixture by this test.
 *
 * Its methods include constructor, change.
 */
class Mutator {
    public:
    strg text

    /*
     * Constructs a Mutator and stores text.
     *
     * Parameters:
     *   initial — strg initial.
     *
     * Returns the constructed Mutator.
     */
    Mutator(strg initial) {
        text = initial
    }

    /*
     * Handles change for this Mutator.
     *
     * Takes no parameters.
     *
     * Returns strg.
     */
    strg change() {
        text.append("!")
        return(text)
    }
}

start {
    Counter counter = Counter()
    strg repeated = format("{value}/{value}", value=counter.next())
    print(repeated)
    print(counter.calls)

    print("{text}: {item_2}", item_2=42, text="result")
    print(
            "{flag} {decimal} {whole} {text}",
        flag=true,
            decimal=1.25,
            whole=42u,
            text="café")
    print("escaped {{braces}} and {name}", name="ok")
    print("runtime type: {kind}", kind=type(42))

    list values = [true, 1.5, "dynamic"]
    print("dynamic value: {value}", value=values[1])
    print("positional {} {}", 7, false)

    Mutator mutator = Mutator("before")
    print("positional snapshot {} {}", mutator.text, mutator.change())
}
