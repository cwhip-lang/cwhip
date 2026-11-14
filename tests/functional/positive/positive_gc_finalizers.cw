# Checks explicit destruction and garbage-collector finalization of unreachable objects.
class Resource {
    public:
    int64 code
    Resource(int64 value) {
        code = value
    }
    destroy {
        print(code)
    }
}

class Maker {
    public:
    void makeExplicit() {
        Resource item = Resource(2)
        item.destroy()
    }

    void makeImplicit() {
        Resource item = Resource(1)
    }
}

start {
    Maker maker = Maker()
    maker.makeExplicit()
    maker.makeImplicit()
    inline { cwhip_gc_collect(); }
    Resource trigger = Resource(3)
    print(trigger.code)
}
