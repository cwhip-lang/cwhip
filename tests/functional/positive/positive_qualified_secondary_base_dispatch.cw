# Selects and dispatches to a method from a specifically qualified secondary base.
class Primary {
    public:
    int64 read() {
        return(1)
    }
}

class Secondary {
    public:
    int64 read() {
        return(2)
    }
}

class QualifiedCombined : Primary, Secondary {
}

start {
    QualifiedCombined combined = QualifiedCombined()
    print(combined.Secondary.read())
}
