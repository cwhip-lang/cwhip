class Primary {
    protected:
    int64 primary
    public:
    Primary() { primary = 10 }
}

class Secondary {
    public:
    int64 secondary
    Secondary() { secondary = 20 }
    void updateSecondary() {
        inline (int64 secondary) { *secondary += 1; }
    }
}

class Fields : Primary, Secondary {
    private:
    int64 own
    strg text
    buffer bytes
    Root saved
    public:
    Fields() {
        super Primary()
        super Secondary()
        inline (int64 own, strg text, buffer bytes) {
            *own = 30;
            *text = cwhip_system_arg(NULL, 0);
            *bytes = cwhip_random_bytes(NULL, 2);
        }
    }
    void update(int64 own) {
        inline (int64 own) { *own += 2; }
        print(own)
        inline (int64 .own, int64 primary, int64 Secondary.secondary) {
            *own += 3;
            *primary += 4;
            *secondary += 5;
        }
        print(text.length > 0)
        print(bytes.length)
        print(Primary.primary)
        print(Secondary.secondary)
    }
    int64 read() { return(own)}
    void shadowLocal() {
        int64 own = 200
        inline (int64 own) { *own += 2; }
        print(own)
    }
    void store(Root input) {
        inline (Root saved, Root input) { *saved = *input; }
        buffer trigger = buffer(1)
        print(saved.shared)
    }
    destroy {
        inline (int64 own) { *own += 7; }
        print(own)
    }
}

class Root {
    public:
    int64 shared
    list values
    Root() { shared = 40 }
    void updateRoot() {
        inline (int64 shared) { *shared += 1; }
    }
}
class Left : virtual Root {}
class Right : virtual Root {}
class Diamond : Left, Right {
    public:
    void update() {
        inline (int64 shared) { *shared += 2; }
        inline (int64 Right.Root.shared) { *shared += 3; }
        inline (list Right.Root.values) { *values = cwhip_system_argv(NULL); }
    }
}

class RepeatedRoot { public: int64 value }
class First : RepeatedRoot {}
class Second : RepeatedRoot {}
class Repeated : First, Second {
    public:
    void update() {
        inline (int64 First.RepeatedRoot.value) { *value = 51; }
        inline (int64 Second.RepeatedRoot.value) { *value = 61; }
    }
}

start {
    Fields fields = Fields()
    fields.update(100)
    fields.shadowLocal()
    fields.Secondary.updateSecondary()
    print(fields.Secondary.secondary)
    print(fields.read())
    fields.destroy()
    Diamond diamond = Diamond()
    diamond.update()
    diamond.Right.Root.updateRoot()
    print(diamond.Left.Root.shared)
    print(diamond.Right.Root.shared)
    print(diamond.Left.Root.values.length > 0)
    fields = Fields()
    fields.store(diamond)
    fields.destroy()
    Repeated repeated = Repeated()
    repeated.update()
    print(repeated.First.RepeatedRoot.value)
    print(repeated.Second.RepeatedRoot.value)
}
