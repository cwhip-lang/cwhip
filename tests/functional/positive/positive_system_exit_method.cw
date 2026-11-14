import system as Sys

class Quitter {
    public:
    void quit(int64 code) {
        print("quitting")
        Sys.System().exit(code)
        print("not reached")
    }
}

start {
    Quitter().quit(9)
    print("not reached")
}
