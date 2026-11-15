/*
 * tests/functional/negative/negative_duplicate_overload.cw
 *
 * Rejects two methods that have the same name AND the same parameter types.
 * Overloading distinguishes methods by parameter type, so an identical
 * parameter list is still a duplicate regardless of return type.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Shape is a class, used as a fixture by this test.
 *
 * Its methods include constructor, area.
 */
class Shape {
    public:
    /*
     * Constructs a Shape.
     *
     * Takes no parameters.
     *
     * Returns the constructed Shape.
     */
    Shape() {
    }

    /*
     * Returns the stored side.
     *
     * Parameters:
     *   side — int64 side.
     *
     * Returns int64.
     */
    int64 area(int64 side) {
        return(side)
    }

    /*
     * Returns 1.0.
     *
     * Parameters:
     *   other — int64 other.
     *
     * Returns fp64.
     */
    fp64 area(int64 other) {
        return(1.0)
    }
}

start {
}
