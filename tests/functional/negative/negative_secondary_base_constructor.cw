# Rejects a multiple-inheritance constructor that omits initialization of its secondary direct base.
class Primary {
    public:
    Primary() {
    }
}

class Secondary {
    public:
    Secondary() {
    }
}

class Combined : Primary, Secondary {
    public:
    Combined() {
        super Primary()
    }
}

start {
}
