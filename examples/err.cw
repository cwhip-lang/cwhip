
namespace Bar {
    class Foo {

        public:
        handle fh
        strg err

        Foo() {}

        void open(strg fname, strg mode) {

            inline(handle fh, strg err, strg fname, strg mode) {
                *fh = cwhip_file_open(NULL, *fname, *mode);
                *err = cwhip_system_last_error(NULL);
            }

            if(err.length > 0) {
                print(format("error opening \"{}\": \"{}\"", fname, err))
            }
        }
    }
}

start {

    Bar.Foo f()
    f.open("foo", "r")
}