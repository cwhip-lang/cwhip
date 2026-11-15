/*
 * tests/functional/modules/packages/enum_values/1.0.0/src/enum_values.cw
 *
 * enum values.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * EnumValues is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class EnumValues {
    public:
    enum {
        FIRST = 80,
        NEXT,
    }

    private:
    enum {
        SECRET = 99
    }
}
