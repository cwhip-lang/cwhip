/*
 * tests/functional/positive/positive_constructor_overloads_out_of_line.cw
 *
 * Checks constructor overloads out of line.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * OutOfLine is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class OutOfLine {
    public:
    /*
     * Constructs a OutOfLine.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed OutOfLine.
     */
    OutOfLine(int64 value)

    /*
     * Constructs a OutOfLine.
     *
     * Parameters:
     *   value — strg value.
     *
     * Returns the constructed OutOfLine.
     */
    OutOfLine(strg value)
}

OutOfLine OutOfLine.OutOfLine(int64 value) {
    print("out int")
}

OutOfLine OutOfLine.OutOfLine(strg value) {
    print("out string")
}

start {
    OutOfLine integer = OutOfLine(1)
    OutOfLine text = OutOfLine("value")
}
