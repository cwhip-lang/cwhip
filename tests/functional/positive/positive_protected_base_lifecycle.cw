class Failure : Exception {
    public:
    Failure(strg text) { super Exception(text) }
}
class Other : Exception {
    public:
    Other(strg text) { super Exception(text) }
}
class Record {
    public:
    Exception original
    Record() { original = null }
    int64 same(Exception left, Exception right)
}
int64 Record.same(Exception left, Exception right) from "cwhip_method_demo_exception_identity"

class First {
    public:
    First() { print("first initialized") }
    destroy { print("INVALID first destructor") }
}
class Fails {
    public:
    Fails() { raise(Failure("base failure")) }
    destroy { print("INVALID failed base destructor") }
}
class Last {
    public:
    Last() { print("INVALID last initialized") }
    destroy { print("INVALID last destructor") }
}
class Rethrows : First, Fails, Last {
    public:
    Rethrows(Record record, bool replace) {
        try {
            super First()
            super Fails()
            super Last()
        } except(Other) {
            raise()
        } except(Failure) as caught {
            record.original = caught
            print(caught.message)
            inline { cwhip_gc_collect(); }
            if (replace) {
                raise(Other("replacement"))
            } else {
                try { raise() }
                except(Failure) { raise() }
                finally { print("nested cleanup") }
            }
        } finally {
            print("initializer cleanup")
        }
        print("INVALID derived continuation")
    }
    destroy { print("INVALID derived destructor") }
}
class Unmatched : Fails {
    public:
    Unmatched() {
        try { super Fails() }
        except(Other) { raise() }
        finally { print("unmatched cleanup") }
    }
}
class CleanupOnly : Fails {
    public:
    CleanupOnly() {
        try { super Fails() }
        finally { print("cleanup without handler") }
    }
}
class Good {
    public:
    Good(int64 value) { print(value) }
}
class Direct : Good {
    public:
    Direct() {
        super Good(10)
        print("direct constructed")
    }
}
class Guarded : Good {
    public:
    Guarded() {
        try { super Good(20) }
        except() { raise(Exception("unexpected failure")) }
        finally { print("success cleanup") }
        print("protected constructed")
    }
}
class More {
    public:
    More() { print("second initialized") }
}
class MultiGood : Good, More {
    public:
    MultiGood() {
        try { super Good(30)
              super More() }
        except() { raise() }
        print("multiple constructed")
    }
}
class Argument {
    public:
    int64 fail() { raise(Failure("argument failure")) }
}
class ArgumentFailure : Good {
    public:
    ArgumentFailure(Argument argument) {
        try { super Good(argument.fail()) }
        except(Failure) { print("argument caught")
                          raise() }
    }
}
class Driver {
    public:
    void run() {
        Record record()
        try { Rethrows item(record, false) }
        except(Failure) as caught {
            print(record.same(record.original, caught))
            print(caught.message)
        } finally { print("outer cleanup") }
        try { Rethrows item(record, true) }
        except(Other) as caught {
            print(caught.message)
            print(record.same(record.original, caught))
        }
        try { Unmatched item() }
        except() as message { print(message) }
        try { CleanupOnly item() }
        except() as message { print(message) }
        Direct direct()
        Guarded guarded()
        MultiGood multiple()
        Argument argument()
        try { ArgumentFailure failed(argument) }
        except() as message { print(message) }
    }
}
start {
    Driver driver()
    driver.run()
    inline { cwhip_gc_collect(); }
    try { raise(Exception("frames still work")) }
    except() as message { print(message) }
}
