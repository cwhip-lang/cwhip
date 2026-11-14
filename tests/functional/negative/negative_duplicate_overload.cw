# Rejects two methods that have the same name AND the same parameter types.
# Overloading distinguishes methods by parameter type, so an identical
# parameter list is still a duplicate regardless of return type.
class Shape {
    public:
    Shape() {}

    int64 area(int64 side) {
        return(side)
    }

    fp64 area(int64 other) {
        return(1.0)
    }
}

start {}
