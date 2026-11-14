# Raises a runtime error when the same object is explicitly destroyed twice.
class Resource {
    public:
    destroy {
    }
}

start {
    Resource resource = Resource()
    resource.destroy()
    resource.destroy()
}
