# Rejects a member that follows private: after an earlier public section.
class Mixed {
    public:
    int64 shown
    private:
    int64 hidden
}

start {
    Mixed mixed = Mixed()
    mixed.shown = 1
    print(mixed.hidden)
}
