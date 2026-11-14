class Payload {
    public:
    int64 code

    Payload(int64 value) {
        code = value
    }
}

class ReturnProbe {
    public:
    int64 evaluations

    strg makeValue() {
        evaluations = evaluations + 1
        return("survived")
    }

    int64 choose(bool first) {
        if (first) {
            { return(10)}
        } else {
            return(20)
        }
    }

    int64 fromLoop() {
        int64 index = 0
        while (index < 3) {
            if (index == 2) { return(index)}
            index = index + 1
        }
        return(-1)
    }

    int64 fromFor() {
        for (item in [int64(1), int64(2)]) {
            int64 value = item
            if (value == 2) { return(value)}
        }
        return(-1)
    }

    int64 fromHandler() {
        try {
            try {
                raise(Exception("go"))
            } except(Exception) {
                return(7)
            } finally {
                print("inner finally")
            }
        } finally {
            print("outer finally")
        }
    }

    strg rootedValue(ReturnProbe self) {
        try {
            return(self.makeValue())
        } finally {
            int64 count = 0
            while (count < 180) {
                strg temporary = "temporary"
                count = count + 1
            }
            print(evaluations)
        }
    }

    Payload rootedObject() {
        try {
            return(Payload(99))
        } finally {
            int64 count = 0
            while (count < 180) {
                Payload temporary = Payload(count)
                count = count + 1
            }
        }
    }

    int64 replacedByException() {
        try {
            return(8)
        } finally {
            raise(Exception("replacement"))
        }
    }

    void earlyExit() {
        do {
            try {
                return
            } finally {
                print("void finally")
            }
        } while (false)
        print("unreachable")
    }
}

start {
    ReturnProbe probe = ReturnProbe()
    print(probe.choose(true))
    print(probe.choose(false))
    print(probe.fromLoop())
    print(probe.fromFor())
    print(probe.fromHandler())
    print(probe.rootedValue(probe))
    print(probe.rootedObject().code)
    try {
        print(probe.replacedByException())
    } except(Exception) as caught {
        print(caught.message)
    }
    probe.earlyExit()
}
