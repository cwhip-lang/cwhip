# Raises a runtime error when a field is read after the object has been explicitly destroyed.
class Resource {
    public:
    int64 value
    Resource(int64 initial) {
        value = initial
    }
    destroy {
    }
}

start {
    Resource resource = Resource(1)
    resource.destroy()
    print(resource.value)
}
