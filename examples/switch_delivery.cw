/*
 * examples/switch_delivery.cw
 *
 * Class enums make compile-time case endpoints readable.
 *
 * Created: 2026-10-24
 * Author: chuck
 *
 * Changelog:
 *   2026-10-24  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Delivery is a class, used by this example.
 *
 * Its methods include describe.
 */
class Delivery {
    public:
    enum {
        FIRST = 1, LAST = 3
    }

    /*
     * Handles describe for this Delivery.
     *
     * Parameters:
     *   day — int64 day.
     *
     * Does not return a value.
     */
    void describe(int64 day) {

        switch (day) {
            case (Delivery.FIRST..Delivery.LAST, 7..5, 10) {
                print("scheduled day {}\n", day)
                next
            }
            // next enters this body without testing whether day equals 99.
            case (99) {
                print("send reminder\n")
            }
            default {
                print("unscheduled day {}\n", day)
            }
        }

    }
}
start {
    Delivery delivery = Delivery()
    delivery.describe(2)
    delivery.describe(6)
    delivery.describe(4)
}
