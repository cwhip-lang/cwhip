import shared as Shared

class Alpha {
    public:
    int64 version() {
        Shared shared = Shared()
        return(shared.version())
    }
}
