# Uses an inline C block inside a method to update a captured parameter before returning it.
class Calculator {
    public:
    int64 adjust(int64 value) {
        inline (int64 value) {
            *value += 2;
        }
        return(value)
    }
}

start {
    print(Calculator().adjust(40))
}
