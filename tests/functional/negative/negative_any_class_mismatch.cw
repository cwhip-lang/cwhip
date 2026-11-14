# Rejects extracting an list-held Cat into Dog because the runtime object has a different exact class.
class Cat {
    public:
    int64 lives
    Cat(int64 initial) {
        lives = initial
    }
}

class Dog {
    public:
    int64 loyalty
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
