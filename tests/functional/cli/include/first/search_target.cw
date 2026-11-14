include "nested_value.cw"
class SearchTarget {
    public:
    int64 answer() {
        NestedValue nested = NestedValue()
        return(40 + nested.value())
    }
}
