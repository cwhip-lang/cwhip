class Foo {
    public:
    Foo() { raise(Exception("original base failure")) }
}
class Bar : Foo {
    public:
    Bar() {
        try { super Foo() }
        except() {
            print("caught locally")
            raise()
        }
        finally { print("local cleanup") }
    }
}
start { Bar b() }
