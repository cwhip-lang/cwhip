namespace main {

    class Foo {

        public:
        int64 main() {
            print("hello from main\n")
            return(0)
        }
    }
}

start {

    main.Foo f()
    f.main()
}
