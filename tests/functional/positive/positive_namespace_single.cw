# Defines and uses a class inside one namespace with a qualified constructor call.
namespace Orchard {
    class Apple {
        public:
        Apple() {}
        int64 sweetness() {
            return(42)
        }
    }
}

start {
    Orchard.Apple apple = Orchard.Apple()
    print(apple.sweetness())
}
