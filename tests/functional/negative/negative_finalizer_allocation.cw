# Raises at runtime when a destructor attempts to allocate another object during finalization.
class Resource {
    public:
    destroy {
        Resource nested = Resource()
    }
}

class Maker {
    public:
    void make() {
        Resource item = Resource()
    }
}

start {
    Maker maker = Maker()
    maker.make()
    inline { cwhip_gc_collect(); }
    Resource trigger = Resource()
}
