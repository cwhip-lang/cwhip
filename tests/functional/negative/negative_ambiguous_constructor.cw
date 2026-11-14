class First {}
class Second {}

class Ambiguous {
    public:
    Ambiguous(First value) {}
    Ambiguous(Second value) {}
}

start {
    Ambiguous value = Ambiguous(null)
}
