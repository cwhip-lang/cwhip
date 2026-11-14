class Bar {
    public:
    int64 val
    Bar(int64 v) { val = v }
    void show() { print(format("class Bar {}", val)) }
}
class Foo {
    public:
    list flarp
    Foo() {
        flarp = []
        int64 i = 0
        while (i <= 10) {
            flarp.append(Bar(i))
            i += 1
        }
    }
}
start {
    Foo f()
    (f.flarp[1] as Bar).show()
}
