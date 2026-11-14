# Verifies an explicit destroy call invokes a class destructor and can access the object state.
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

start {
    Resource resource = Resource(42)
    resource.destroy()
}
