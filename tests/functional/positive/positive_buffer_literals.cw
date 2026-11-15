/*
 * tests/functional/positive/positive_buffer_literals.cw
 *
 * Explicit buffer literals evaluate their integer elements once from left to
 * right.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Builder is a class, used as a fixture by this test.
 *
 * Its methods include constructor, next, nextUnsigned, count, identity, fail.
 */
class Builder {
    public:
    int64 calls

    /*
     * Constructs a Builder and stores calls.
     *
     * Takes no parameters.
     *
     * Returns the constructed Builder.
     */
    Builder() {
        calls = 0
    }

    /*
     * Handles next for this Builder.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns int64.
     */
    int64 next(int64 value) {
        calls = calls + 1
        print(calls)
        return(value)
    }

    /*
     * Handles next unsigned for this Builder.
     *
     * Parameters:
     *   value — uint64 value.
     *
     * Returns uint64.
     */
    uint64 nextUnsigned(uint64 value) {
        calls = calls + 1
        print(calls)
        return(value)
    }

    /*
     * Returns the stored calls.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 count() {
        return(calls)
    }

    /*
     * Returns the stored value.
     *
     * Parameters:
     *   value — buffer value.
     *
     * Returns buffer.
     */
    buffer identity(buffer value) {
        return(value)
    }

    /*
     * Handles fail for this Builder. Raises Exception when the call is not
     * valid (buffer literal stopped).
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 fail() {
        raise(Exception("buffer literal stopped"))
    }
}

start {
    Builder builder = Builder()
    buffer empty = buffer[]
    print(empty.length)

    buffer bytes = buffer[
        builder.next(-1),
        builder.next(256),
        builder.nextUnsigned(18446744073709551615u)
    ]
    print(bytes.length)
    print(bytes[0])
    print(bytes[1])
    print(bytes[2])

    buffer zeroFilled = buffer(2)
    print(zeroFilled.length)
    print(zeroFilled[0])
    print(zeroFilled[1])

    buffer first = buffer[1]
    buffer second = buffer[1]
    second[0] = 9
    print(first[0])
    print(second[0])

    buffer passed = builder.identity(buffer[builder.next(258)])
    print(passed[0])
    passed = buffer[builder.nextUnsigned(510u)]
    print(passed[0])

    list values = [1, 2u]
    print(values[0])
    print(values[1])

    try {
        buffer aborted = buffer[
            builder.next(77),
            builder.fail(),
            builder.next(88)
        ]
    }
    except() {
        print("caught")
    }
    print(builder.count())
}
