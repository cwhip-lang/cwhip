// Class enums make compile-time case endpoints readable.
class Delivery {
    public:
    enum { FIRST = 1, LAST = 3 }
    void describe(int64 day) {
        switch (day) {
            case (Delivery.FIRST..Delivery.LAST, 7..5, 10) {
                print("scheduled day {}\n", day)
                next
            }
            // next enters this body without testing whether day equals 99.
            case (99) { print("send reminder\n") }
            default { print("unscheduled day {}\n", day) }
        }
    }
}
start {
    Delivery delivery = Delivery()
    delivery.describe(2)
    delivery.describe(6)
    delivery.describe(4)
}
