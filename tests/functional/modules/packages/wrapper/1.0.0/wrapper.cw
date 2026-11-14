import greeting as G

class Wrapper {
    public:
    Wrapper() {}
    int64 answer() {
        return(G().answer())
    }
}
