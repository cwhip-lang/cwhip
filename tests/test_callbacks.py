"""Compile/link/run bound callbacks and the public native bridge, hermetically."""

import argparse
from pathlib import Path
import signal
import subprocess
import tempfile

from program_runner import environment, invoke


NATIVE = """
class Native {
    public:
    handle register(int64<int64> cb)
    int64 invoke(handle registration, int64 value)
    void release(handle registration)
    void dispose(handle registration)
    void collect()
    void foreign(handle registration)
    void registeredForeign(handle registration)
    void unlocked(handle registration)
    handle transfer(int64<int64> cb)
    handle accept(handle transfer)
    void cancel(handle transfer)
    void transferWorker(handle transfer)
    void unregisteredEnter()
}
handle Native.register(int64<int64> cb) from "fixture_callback_register"
int64 Native.invoke(handle registration, int64 value) from "fixture_callback_invoke"
void Native.release(handle registration) from "fixture_callback_release"
void Native.dispose(handle registration) from "fixture_callback_dispose"
void Native.collect() from "fixture_callback_collect"
void Native.foreign(handle registration) from "fixture_callback_foreign"
void Native.registeredForeign(handle registration) from "fixture_callback_registered_foreign"
void Native.unlocked(handle registration) from "fixture_callback_unlocked"
handle Native.transfer(int64<int64> cb) from "fixture_callback_transfer"
handle Native.accept(handle transfer) from "fixture_callback_accept"
void Native.cancel(handle transfer) from "fixture_callback_cancel"
void Native.transferWorker(handle transfer) from "fixture_callback_transfer_worker"
void Native.unregisteredEnter() from "fixture_callback_unregistered_enter"
"""


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--compiler", type=Path, required=True)
    parser.add_argument("--clang", required=True)
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--fixture", type=Path, required=True)
    parser.add_argument("--work", type=Path, required=True)
    parser.add_argument("--sanitize", default="")
    args = parser.parse_args()
    args.work.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=args.work, prefix="callbacks-") as directory:
        work = Path(directory)
        env = environment(work)
        native = work / "native.o"
        flags = [f"-fsanitize={args.sanitize}"] if args.sanitize else []
        result = invoke([args.clang, "-std=c11", "-I", str(args.include.resolve()),
                         "-c", str(args.fixture.resolve()), "-o", str(native)] + flags, work, env)
        assert result.returncode == 0, result.stderr
        result = invoke([args.clang, "-x", "c++", "-std=c++17", "-fsyntax-only",
                         "-I", str(args.include.resolve()), "-"], work, env,
                        '#include <cwhip/Callbacks.h>\n'
                        'static_assert(sizeof(CwhipCallbackArgument) >= sizeof(void *));\n')
        assert result.returncode == 0, result.stderr
        cases = [
            ("transfer_roots", NATIVE + """
class Payload {
    public:
    int64 run(int64 n) { return(n + 2) }
    destroy { print("disposed") }
}
class Factory {
    public:
    handle prepare(Native n) { return(n.transfer(Payload().run)) }
}
start {
    Native n = Native()
    handle transfer = Factory().prepare(n)
    n.collect()
    handle context = n.accept(transfer)
    n.collect()
    print(n.invoke(context, 40))
    n.release(context)
    n.dispose(context)
    n.collect()
    transfer = Factory().prepare(n)
    n.collect()
    n.cancel(transfer)
    n.collect()
    transfer = Factory().prepare(n)
    n.transferWorker(transfer)
    n.collect()
}
""", "42disposeddisposeddisposed", None),
            ("managed_reentry", """
start {
    inline() {
        if (cwhip_runtime_managed_enter() != 0) abort();
        cwhip_runtime_managed_leave(0);
        cwhip_runtime_gil_release();
        int acquired = cwhip_runtime_managed_enter();
        if (acquired != 1 || cwhip_runtime_managed_enter() != 0) abort();
        cwhip_gc_collect();
        cwhip_runtime_managed_leave(0);
        cwhip_runtime_managed_leave(acquired);
        cwhip_runtime_gil_acquire();
    }
    print("reentered")
}
""", "reentered", None),
            ("unregistered_reentry", NATIVE + """
start { Native().unregisteredEnter() }
""", "", "native reentry requires a registered thread"),
            ("transfer_signature", """
class Payload { public: void run() {} }
start {
    void<> cb = Payload().run
    inline(void<> cb) {
        cwhip_callback_transfer_prepare(*cb, "callback<int64(int64)>");
    }
}
""", "", "signature mismatch"),
            ("native_abis", NATIVE + """
class W {
    public:
    strg mixed(strg text, int64 i, uint64 u, fp64 f, bool b,
               list xs, dict d, buffer bytes, handle opaque) {
        Native().collect()
        print("{} {} {} {} {} {} {} {}", i, u, f, b,
              xs.length, d.length, bytes.length, opaque == null)
        return(text)
    }
    bool yes(bool b) { return(not b) }
    uint64 twice(uint64 n) { return(n + n) }
    fp64 half(fp64 n) { return(n / 2.0) }
    void ping() { print("ping") }
    list keepList(list values) { Native().collect()
        return(values) }
    int64<int64> echo(int64<int64> cb) { return(cb) }
    int64 add(int64 n) { return(n + 2) }
}
start {
    W w = W()
    strg<strg,int64,uint64,fp64,bool,list,dict,buffer,handle> mixed = w.mixed
    bool<bool> yes = w.yes
    uint64<uint64> twice = w.twice
    fp64<fp64> half = w.half
    void<> ping = w.ping
    list<list> keep = w.keepList
    list kept = null
    int64<int64><int64<int64>> echo = w.echo
    int64<int64> add = w.add
    int64<int64> echoed = null
    strg text = "native"
    strg output = null
    list xs = [1, 2]
    dict d = ["key": 3]
    buffer bytes = buffer(3)
    inline(strg<strg,int64,uint64,fp64,bool,list,dict,buffer,handle> mixed,
           bool<bool> yes, uint64<uint64> twice,
           fp64<fp64> half, void<> ping,
           list<list> keep, list kept,
           int64<int64><int64<int64>> echo,
           int64<int64> add, int64<int64> echoed,
           strg text, strg output, list xs, dict d, buffer bytes) {
        CwhipCallbackContext *c = cwhip_callback_acquire(*mixed,
            "callback<String(String,int64,uint64,fp64,bool,list,dict,buffer,handle)>");
        typedef void *(*Mixed)(CwhipCallbackContext *, void *, int64_t, uint64_t,
                              double, _Bool, void *, void *, void *, void *);
        *output = ((Mixed)cwhip_callback_adapter(c))(c, *text, -4,
            UINT64_C(18446744073709551615), 1.5, 1, *xs, *d, *bytes, NULL);
        cwhip_callback_release(c);
        cwhip_callback_dispose(c);
        c = cwhip_callback_acquire(*yes, "callback<bool(bool)>");
        if (((_Bool (*)(CwhipCallbackContext *, _Bool))cwhip_callback_adapter(c))(c, 1))
            abort();
        cwhip_callback_release(c);
        cwhip_callback_dispose(c);
        c = cwhip_callback_acquire(*twice, "callback<uint64(uint64)>");
        if (((uint64_t (*)(CwhipCallbackContext *, uint64_t))cwhip_callback_adapter(c))(c, 10) != 20)
            abort();
        cwhip_callback_release(c);
        cwhip_callback_dispose(c);
        c = cwhip_callback_acquire(*half, "callback<fp64(fp64)>");
        if (((double (*)(CwhipCallbackContext *, double))cwhip_callback_adapter(c))(c, 7.0) != 3.5)
            abort();
        cwhip_callback_release(c);
        cwhip_callback_dispose(c);
        c = cwhip_callback_acquire(*ping, "callback<void()>");
        ((void (*)(CwhipCallbackContext *))cwhip_callback_adapter(c))(c);
        cwhip_callback_release(c);
        cwhip_callback_dispose(c);
        c = cwhip_callback_acquire(*keep, "callback<list(list)>");
        void *only_argument = cwhip_gc_alloc_array(5);
        *kept = ((void *(*)(CwhipCallbackContext *, void *))cwhip_callback_adapter(c))(c, only_argument);
        cwhip_callback_release(c);
        cwhip_callback_dispose(c);
        c = cwhip_callback_acquire(*echo, "callback<callback<int64(int64)>(callback<int64(int64)>)>");
        CwhipCallbackArgument arguments[1] = {{0}}, result = {0};
        arguments[0].pointer = *add;
        cwhip_callback_context_invoke(c, "callback<callback<int64(int64)>(callback<int64(int64)>)>",
                                     arguments, &result);
        *echoed = result.pointer;
        cwhip_callback_release(c);
        cwhip_callback_dispose(c);
    }
    print(output)
    print(echoed(40))
    print(kept.length)
}
""", "-4 18446744073709551615 1.5 true 2 1 3 truepingnative425", None),
            ("contexts", """
class W {
    public:
    int64 run(int64 n) { return(n + 1) }
    fp64 run(fp64 n) { return(n + 0.5) }
}
class Use {
    public:
    int64 use(int64<int64> cb, int64 value) { return(cb(value)) }
    fp64 use(fp64<fp64> cb, fp64 value) { return(cb(value)) }
    int64<int64> saved
    Use(int64<int64> cb) { saved = cb }
    Use(fp64<fp64> cb, fp64 value) { print(cb(value)) }
    int64<int64> get()
}
int64<int64> Use.get() { return(saved) }
start {
    W w = W()
    int64<int64> integerRun = w.run
    fp64<fp64> floatingRun = w.run
    Use u = Use(w.run)
    print(u.use(integerRun, 41))
    print(u.use(floatingRun, 1.5))
    print(u.get()(9))
}
""", "42210", None),
            ("simple_roots", NATIVE + """
class W {
    public:
    int64 run(int64 n) { return(n + 40) }
    destroy { print("finalized") }
}
class Box {
    public:
    int64<int64> cb
    int64<int64> make() {
        W local = W()
        return(local.run)
    }
}
start {
    Native n = Native()
    Box b = Box()
    print(b.cb == null)
    b.cb = b.make()
    n.collect()
    print(b.cb(2))
}
""", "true42", None),
            ("values", """
class Worker {
    public:
    int64 bias
    Worker(int64 initial) { bias = initial }
    int64 add(int64 n) { return(bias + n) }
    fp64 add(fp64 n) { return(n + 0.5) }
    strg echo(strg value) { return(value) }
    Worker object(Worker value) { return(value) }
    void ping() { print("ping") }
}
class Box {
    public:
    int64<int64> value
    int64<int64> pass(int64<int64> cb) { return(cb) }
    int64 apply(int64<int64> cb, int64 x) { return(cb(x)) }
}
class Factory {
    public:
    int64 count
    Worker make() {
        count += 1
        return(Worker(10))
    }
}
start {
    Worker w(20)
    Box b
    b = Box()
    b.value = w.add
    int64<int64> cb = b.pass(b.value)
    print("{} {} {}", cb(2), b.value(3), b.apply(w.add, 4))
    fp64<fp64> fp = w.add
    print(fp(1.5))
    strg<strg> text = w.echo
    print(text("managed"))
    Worker<Worker> obj = w.object
    Worker same = obj(w)
    print(same.bias)
    void<> ping = w.ping
    ping()
    Factory f = Factory()
    int64<int64> once = f.make().add
    print("{} {}", f.count, once(7))
    int64<int64> empty = null
    print("{} {} {}", empty == null, cb == cb, cb != empty)
    int64<int64> independent = w.add
    print(cb != independent)
    print(type(empty))
    print(type(cb))
}
""", "22 23 242managed20ping1 17true true truetruenullcallback<int64(int64)>", None),
            ("exceptions", """
class Worker {
    public:
    int64 fail(int64 n) { return(1 / n) }
    destroy { print("destroyed") }
}
start {
    Worker w = Worker()
    int64<int64> cb = w.fail
    try { print(cb(0)) } except(Exception) as e { print("caught") }
    w.destroy()
    try { print(cb(1)) } except(Exception) as e { print("dead") }
    try {
        int64<int64> invalid = w.fail
    } except(Exception) as e { print("capture dead") }
    Worker nil = null
    try {
        int64<int64> invalid = nil.fail
    } except(Exception) as e { print("capture null") }
    int64<int64> empty = null
    try { print(empty(1)) } except(Exception) as e { print("empty") }
}
""", "caughtdestroyeddeadcapture deadcapture nullempty", None),
            ("virtual", """
class First { public: int64 f() { return(1) } }
class Base { public: int64 value(int64 n) { return(n + 2) } }
class Derived : First, Base { public: int64 value(int64 n) { return(n + 20) } }
class Left : virtual Base {}
class Right : virtual Base {}
class Diamond : Left, Right { public: int64 value(int64 n) { return(n + 200) } }
start {
    Derived d = Derived()
    Base b = d
    int64<int64> secondary = b.value
    int64<int64> qualified = d.Base.value
    print("{} {}", secondary(1), qualified(2))
    Diamond diamond = Diamond()
    Base virtualBase = diamond
    int64<int64> virtualCb = virtualBase.value
    int64<int64> virtualQualified = diamond.Left.Base.value
    print("{} {}", virtualCb(1), virtualQualified(2))
}
""", "21 22201 202", None),
            ("native_roots", NATIVE + """
class Worker {
    public:
    int64 base
    Worker(int64 initial) { base = initial }
    int64 add(int64 value) { return(base + value) }
    destroy { print("finalized") }
}
class Factory {
    public:
    handle make(Native native) {
        Worker w(40)
        return(native.register(w.add))
    }
    handle quiet(Native native) {
        Quiet w = Quiet()
        return(native.register(w.add))
    }
}
class Quiet { public: int64 add(int64 value) { return(value) } }
start {
    Native n = Native()
    Factory factory = Factory()
    handle registration = factory.make(n)
    n.collect()
    print(n.invoke(registration, 2))
    n.release(registration)
    n.collect()
    n.dispose(registration)
    int64 count = 0
    while (count < 50) {
        handle next = factory.quiet(n)
        n.invoke(next, count)
        n.release(next)
        n.dispose(next)
        count += 1
    }
    print(count)
}
""", "42finalized50", None),
            ("native_exception", NATIVE + """
class Worker { public: int64 fail(int64 n) { return(1 / n) } }
start {
    Native n = Native()
    Worker w = Worker()
    handle registration = n.register(w.fail)
    try { print(n.invoke(registration, 0)) } except(Exception) as e { print("escaped") }
}
""", "", "uncaught Cwhip exception"),
            ("released", NATIVE + """
class Worker { public: int64 run(int64 n) { return(n) } }
start {
    Native n = Native()
    Worker w = Worker()
    handle registration = n.register(w.run)
    n.release(registration)
    print(n.invoke(registration, 1))
}
""", "", "registration has been released"),
            ("foreign", NATIVE + """
class Worker { public: int64 run(int64 n) { return(n) } }
start {
    Native n = Native()
    Worker w = Worker()
    handle registration = n.register(w.run)
    n.foreign(registration)
}
""", "", "registered Cwhip thread"),
            ("reentrant", NATIVE + """
class Worker {
    public:
    Native native
    handle registration
    int64 depth
    int64 run(int64 n) {
        if (depth == 0) {
            depth = 1
            int64 inner = native.invoke(registration, n + 1)
            depth = 0
            return(inner + 10)
        }
        native.collect()
        return(n)
    }
}
start {
    Native n = Native()
    Worker w = Worker()
    w.native = n
    w.registration = n.register(w.run)
    print(n.invoke(w.registration, 1))
    n.release(w.registration)
    n.dispose(w.registration)
}
""", "12", None),
            ("in_flight_release", NATIVE + """
class Worker {
    public:
    Native native
    handle registration
    int64 run(int64 n) { native.release(registration)
        return(n) }
}
start {
    Native n = Native()
    Worker w = Worker()
    w.native = n
    w.registration = n.register(w.run)
    n.invoke(w.registration, 1)
}
""", "", "in-flight registration"),
            ("native_signature", """
class W { public: int64 run(int64 n) { return(n) } }
start {
    W w = W()
    int64<int64> cb = w.run
    inline(int64<int64> cb) {
        cwhip_callback_acquire(*cb, "callback<fp64(fp64)>");
    }
}
""", "", "signature mismatch"),
            ("native_destroyed", NATIVE + """
class W {
    public:
    int64 run(int64 n) { return(n) }
    destroy {}
}
start {
    Native n = Native()
    W w = W()
    handle registration = n.register(w.run)
    w.destroy()
    n.invoke(registration, 1)
}
""", "", "object has been destroyed"),
            ("native_caught", NATIVE + """
class W {
    public:
    int64 run(int64 n) {
        try { return(1 / n) } except() { return(-1) }
    }
}
start {
    Native n = Native()
    W w = W()
    handle registration = n.register(w.run)
    print(n.invoke(registration, 0))
    n.release(registration)
    n.dispose(registration)
}
""", "-1", None),
            ("registered_foreign", NATIVE + """
class W { public: int64 run(int64 n) { return(n) } }
start {
    Native n = Native()
    W w = W()
    handle registration = n.register(w.run)
    n.registeredForeign(registration)
}
""", "", "foreign-thread invocation"),
            ("unlocked", NATIVE + """
class W { public: int64 run(int64 n) { return(n) } }
start {
    Native n = Native()
    W w = W()
    handle registration = n.register(w.run)
    n.unlocked(registration)
}
""", "", "holding the runtime lock"),
            ("undisposed", NATIVE + """
class W { public: int64 run(int64 n) { return(n) } }
start {
    Native n = Native()
    W w = W()
    handle registration = n.register(w.run)
    n.release(registration)
}
""", "", "undisposed callback registrations"),
            ("double_release", NATIVE + """
class W { public: int64 run(int64 n) { return(n) } }
start {
    Native n = Native()
    W w = W()
    handle registration = n.register(w.run)
    n.release(registration)
    n.release(registration)
}
""", "", "registration has been released"),
            ("early_dispose", NATIVE + """
class W { public: int64 run(int64 n) { return(n) } }
start {
    Native n = Native()
    W w = W()
    handle registration = n.register(w.run)
    n.dispose(registration)
}
""", "", "idle released owner-thread registration"),
            ("argument_destroys", """
class W {
    public:
    int64 run(int64 n) { return(42) }
    destroy {}
}
class Killer {
    public:
    int64 kill(W object) { object.destroy()
        return(1) }
}
start {
    W w = W()
    int64<int64> cb = w.run
    try { print(cb(Killer().kill(w))) } except() { print("dead") }
}
""", "dead", None),
        ]
        for name, source, output, diagnostic in cases:
            path = work / f"{name}.cw"
            path.write_text(source)
            executable = work / name
            result = invoke([str(args.compiler.resolve()), str(path), str(native),
                             "-o", str(executable)] + (["-g"] if name == "values" else []),
                            work, env)
            assert result.returncode == 0, f"{name}: {result.stderr}"
            result = invoke([str(executable)], work, env)
            if diagnostic:
                assert result.returncode == -signal.SIGABRT and diagnostic in result.stderr, (name, result)
                assert "escaped" not in result.stdout, result
            else:
                assert result.returncode == 0 and result.stdout == output, (name, result)
                assert not result.stderr, (name, result)
            print(f"PASS {name}")

        prefix = """class W {
    public:
    int64 run(int64 n) { return(n) }
    fp64 run(fp64 n) { return(n) }
    private:
    int64 secret(int64 n) { return(n) }
    destroy {}
}
"""
        negative = [
            ("mismatch", "fp64<int64> cb = w.run", "does not match callback signature"),
            ("arity", "int64<int64> cb = w.run\n cb()", "argument count mismatch"),
            ("argument", 'int64<int64> cb = w.run\n cb("x")', "argument type mismatch"),
            ("access", "int64<int64> cb = w.secret", "not accessible"),
            ("ambiguity", "print(w.run)", "ambiguous callback capture"),
            ("collection", "int64<int64> cb = w.run\n list values = [cb]", "list elements"),
            ("type_test", "int64<int64> cb = w.run\n print(cb is int64)", "does not support operand"),
            ("conversion", "int64<int64> cb = w.run\n fp64<fp64> other = cb", "cannot initialize"),
            ("void_argument", "int64<void> cb = w.run", "expected type name"),
            ("descriptor", "type<> cb = w.run", "type descriptors"),
            ("free", "int64<int64> cb = W.run", "undefined variable"),
            ("cast", "int64<int64> cb = w.run\n handle h = cb as handle", "does not support source"),
            ("callback_test", "int64<int64> cb = w.run\n print(cb is int64<int64>)",
             "callback type tests and casts are not supported"),
            ("default", "int64<int64> cb\n cb(1)", "may be uninitialized"),
            ("overload_context", """Use u = Use()
 u.use(w.run)
""", "ambiguous between overloads"),
            ("destructor", "void<> cb = w.destroy", "destructors cannot be captured"),
            ("map", 'int64<int64> cb = w.run\n dict d = ["cb": cb]', "dict values"),
            ("inheritance_ambiguity", "Both b = Both()\n int64<int64> cb = b.run",
             "ambiguous inherited callback method"),
            ("private_base", "Hidden h = Hidden()\n int64<int64> cb = h.A.run",
             "not accessible"),
        ]
        prefix += """class Use {
    public:
    int64 use(int64<int64> cb) { return(cb(1)) }
    fp64 use(fp64<fp64> cb) { return(cb(1.0)) }
}
class A { public: int64 run(int64 n) { return(n) } }
class B { public: int64 run(int64 n) { return(n) } }
class Both : A, B {}
class Hidden : private A {}
"""
        for name, statement, diagnostic in negative:
            path = work / f"negative_{name}.cw"
            path.write_text(prefix + "start {\n W w = W()\n" + statement + "\n}\n")
            result = invoke([str(args.compiler.resolve()), str(path), "--check-only"], work, env)
            assert result.returncode != 0 and diagnostic in result.stderr, (name, result)
            print(f"PASS negative_{name}")
        module = work / "modules" / "callbacks" / "1.0.0"
        module.mkdir(parents=True)
        (module / "cwhip-package.toml").write_text(
            '[package]\nsdk-abi = "numeric-v2"\nname = "callbacks"\nversion = "1.0.0"\n'
            'source = "model.cw"\nexport = "namespace:Model"\n')
        (module / "model.cw").write_text("""
namespace Model {
    class Cell {
        public:
        int64 n
        Cell(int64 initial) { n = initial }
        Cell echo(Cell other) { return(other) }
        Cell<Cell> capture() { return(echoReceiver().echo) }
        Cell echoReceiver() { return(Cell(n)) }
    }
}
""")
        path = work / "imported.cw"
        path.write_text("""
import callbacks as Cb
start {
    Cb.Cell cell(42)
    Cb.Cell<Cb.Cell> cb = cell.capture()
    Cb.Cell result = cb(cell)
    print(result.n)
    inline(Cb.Cell<Cb.Cell> cb, Cb.Cell cell, Cb.Cell result) {
        CwhipCallbackContext *context = cwhip_callback_acquire(*cb, "callback<Model.Cell(Model.Cell)>");
        *result = ((void *(*)(CwhipCallbackContext *, void *))cwhip_callback_adapter(context))(context, *cell);
        cwhip_callback_release(context);
        cwhip_callback_dispose(context);
    }
    print(result.n)
}
""")
        executable = work / "imported"
        result = invoke([str(args.compiler.resolve()), str(path), "-o", str(executable)],
                        work, env)
        assert result.returncode == 0, result.stderr
        result = invoke([str(executable)], work, env)
        assert result.returncode == 0 and result.stdout == "4242" and not result.stderr, result
        print("PASS imported_namespace")
    print(f"Checked {len(cases) + len(negative) + 1} callback cases")


if __name__ == "__main__":
    main()
