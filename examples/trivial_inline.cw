
class Foo {

    public:
    int64 num

    void setup() {
        num = 123
    }

    void pstr(strg s) {

        inline (strg s){
            printf("this is the %s string\n", cwhip_string_cstr(s));
        }
    }

    void pnum(int64 val) {

        inline(int64 val) {
            printf("this is the %lld number\n", (long long)*val);
        }
    }
}

start {

    Foo f()
    f.setup()
    f.pnum(8086)
    f.pstr("good")
}