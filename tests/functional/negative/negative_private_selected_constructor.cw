class ProtectedChoice {
    public:
    ProtectedChoice(int64 value) {}

    private:
    ProtectedChoice(strg value) {}
}

start {
    ProtectedChoice value = ProtectedChoice("private")
}
