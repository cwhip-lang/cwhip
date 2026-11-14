# Public sections expose members, and a later private member stays usable inside the class.
class Mixed {
    public:
    int64 shown
    int64 reveal() {
        hidden = 7
        return(hidden)
    }
    private:
    int64 hidden
}

start {
    Mixed mixed = Mixed()
    mixed.shown = 4
    print(mixed.shown)
    print(mixed.reveal())
}
