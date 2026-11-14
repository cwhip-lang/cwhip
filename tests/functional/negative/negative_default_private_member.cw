# Rejects a member that has no access section when it is used outside the class.
class Hidden {
    int64 value
    public:
    Hidden() {
    }
    int64 read() {
        return(value)
    }
}

start {
    Hidden hidden = Hidden()
    print(hidden.value)
}
