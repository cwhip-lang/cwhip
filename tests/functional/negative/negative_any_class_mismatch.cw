/*
 * tests/functional/negative/negative_any_class_mismatch.cw
 *
 * Rejects extracting an list-held Cat into Dog because the runtime object has
 * a different exact class.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Cat is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Cat {
    public:
    int64 lives

    /*
     * Constructs a Cat and stores lives.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Cat.
     */
    Cat(int64 initial) {
        lives = initial
    }
}

/*
 * Dog is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Dog {
    public:
    int64 loyalty

    /*
     * Constructs a Dog and stores loyalty.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Dog.
     */
    Dog(int64 initial) {
        loyalty = initial
    }
}

start {
    // Extraction into a class type requires an exact runtime class match;
    // this prototype does not support polymorphic/covariant downcasts.
    list pets = [Cat(9), Dog(1)]
    Dog mismatched = pets[0]
    print(mismatched.loyalty)
}
