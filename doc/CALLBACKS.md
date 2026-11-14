# Bound-method callbacks and the native bridge

`R<P1,P2>` is a nullable, GC-managed callable value. `R` is a declared return
type (including `void`); `P1` and `P2` are parameter types, without names.
Zero parameters use `R<>`. Callable types are recursive: for example,
`int64<int64><String>` takes a `String` and returns an `int64<int64>` callable.
`range<T>` remains a range type, including when nested as a callable return or
parameter. `any` and `type` descriptors are not supported in signatures.
`strg` and `String` denote the same signature type.

```cwhip
// test: {"stdout": "42"}
class Counter {
    public:
    int64 base
    Counter(int64 initial) { base = initial }
    int64 add(int64 value) { return(base + value)}
}
class Apply {
    public:
    int64 run(int64<int64> action, int64 value) { return(action(value))}
}
start {
    Counter counter(40)
    int64<int64> action = counter.add
    print(Apply().run(action, 2))
}
```

Omitting `()` captures the bound method rather than calling it. Capture evaluates
the receiver exactly once and checks it for null and destruction. A callback
retains the receiver, including a secondary or virtual base view, through GC.
Dispatch uses the receiver's virtual table, including overrides, rather than a
public method symbol. Explicit destruction still invalidates invocation; holding
a callback does not make destruction reversible. Cwhip invocation propagates exceptions normally.

Callbacks can be stored in locals and fields, passed, returned, and invoked.
Callback fields initially hold null; locals must be initialized before use, as
with other locals. Null assignment/comparison is allowed; null invocation raises
a catchable exception. Equality requires identical signatures and compares
callback **value identity**: copying a value preserves identity, but two separate
captures of the same method create different values. No signature covariance,
implicit conversion, or cast is provided. `type(action)` returns its canonical
signature (or `null` for a null value). `is` tests and checked casts involving
callbacks, printing callbacks, and storing them in dynamic lists/dicts are
diagnosed as unsupported. No anonymous functions, lexical closures, free-function
captures, destructor captures, or unbound member pointers are provided.

An expected callback type selects an exactly matching method overload, including
parameter **and return** types. Overloaded receiving methods/constructors provide
candidate signature contexts; if more than one candidate remains viable, the
call is ambiguous. Access and inheritance-path checks apply at capture.

## Installed C API

Include `<cwhip/Callbacks.h>`. The header is installed and staged alongside
`<cwhip/Stdlib.h>`; its functions are supplied by `libcwhip_runtime`. Native-bound
callback parameters/results use a single opaque `void *`, just like managed
class references. Inline captures receive `void **`, the address of the
callback's rooted Cwhip slot. Do not dereference a callback's private layout or
call Cwhip method symbols from C.

`cwhip_callback_acquire(callback, signature)` creates a retained registration.
The signature string is **canonical ABI text**, e.g. `callback<int64(int64)>`,
`callback<String(String)>`, or `callback<Model.Cell(Model.Cell)>`, with no
spaces. Namespace/import aliases must be expanded to the declared namespace.
Source declarations use `R<P...>`; these canonical strings intentionally keep
the existing `callback<R(P...)>` encoding for native consumers and runtime
interop. The syntax revision does not change callback bridge symbols or the
SDK ABI version.
An incorrect signature is a fatal native-boundary error, not a function-pointer
cast. `cwhip_callback_signature(context)` returns the immutable canonical string.

`cwhip_callback_adapter(context)` returns a function pointer that must be converted
to its **exact** signature:

```c
#include <cwhip/Callbacks.h>

typedef int64_t (*OnValue)(CwhipCallbackContext *, int64_t);

/* Called by a native-bound method or inline shim on a Cwhip thread. */
CwhipCallbackContext *context =
    cwhip_callback_acquire(callback, "callback<int64(int64)>");
OnValue function = (OnValue)cwhip_callback_adapter(context);
int64_t answer = function(context, 42);
/* Disconnect the C API's registration before releasing the retained root. */
cwhip_callback_release(context);
/* Dispose only when the C library can no longer use the context pointer. */
cwhip_callback_dispose(context);
```

The generated adapter's ABI is `R(CwhipCallbackContext *, P1, P2, ...)`.
`int8`/`uint8` through `int64`/`uint64` use their exact-width C integer types;
`fp32` is C `float`, `fp64` is `double`, and `bool` is
C `_Bool`, and managed references/handles are `void *`. A `void` result really
returns C `void`. Parameters keep their order. Use a small statically compiled
C forwarding function for APIs placing `void *user_data` last or otherwise
reordering it; it calls this exact adapter with context first. APIs that accept
only a bare function pointer are unsupported. Adapters are compiled per signature,
not dynamically generated executable per-object trampolines.

The same API works in a hermetic inline shim:

```cwhip
// test: {"stdout": "42"}
class Worker {
    public:
    int64 add(int64 value) { return(value + 2)}
}
start {
    Worker worker = Worker()
    int64<int64> action = worker.add
    int64 result = 0
    inline(int64<int64> action, int64 result) {
        CwhipCallbackContext *context =
            cwhip_callback_acquire(*action, "callback<int64(int64)>");
        typedef int64_t (*OnValue)(CwhipCallbackContext *, int64_t);
        OnValue function = (OnValue)cwhip_callback_adapter(context);
        *result = function(context, 40);
        cwhip_callback_release(context);
        cwhip_callback_dispose(context);
    }
    print(result)
}
```

Alternatively, `cwhip_callback_context_invoke(context, signature, arguments,
result)` invokes through the same boundary using an array of
`CwhipCallbackArgument` unions: `integer`, `unsigned_integer`, `floating`,
`boolean`, or `pointer`, according to the signature. Pass non-null result storage
even for void; it is not written in that case. A zero-argument call may pass null
arguments. This low-level API requires exactly the signature's argument count
and union members, just as a C function call requires its exact argument types.

## Lifetime, rooting, and boundary policy

Acquisition roots the callback and its captured receiver until release, even
after all Cwhip locals/fields referring to them go out of scope. Managed native
arguments are rooted throughout invocation, including allocations and reentry.
Managed results are borrowed: immediately store them in a captured/rooted Cwhip
slot before another allocating runtime call. Native pointers alone are not roots.

The C library owns neither the callback nor the context's storage. Disconnect
first, then release. Release during any invocation of that registration is
rejected. Release removes its GC root but keeps a tombstone: invocation, adapter
lookup, signature lookup, and repeated release after release explicitly abort
instead of using a dangling receiver. Disposal frees the tombstone and requires
an idle, released registration. **No pointer may be used after disposal**; C
code must guarantee disconnection and completion before disposing. Always release
and dispose registrations before their owner thread exits; exiting with an
undisposed registration is a fatal error. Different acquisitions
are independent registrations.

All registration operations and invocation require the acquiring Cwhip thread,
registered with the runtime and currently holding its managed-code lock. Foreign
threads, including another registered Cwhip thread, are rejected with an
explicit fatal diagnostic before executing managed code. Do not invoke while a
native primitive has released the runtime lock. Same-thread synchronous reentry
is supported: nested invocations have independent exception/root frames and
in-flight counts. These generic registrations are not transferable. The optional
[GTK foundation](GTK.md) adds a package-local GUI scheduler without weakening
these checks.

### Rooted one-shot transport and native loop reentry

For package authors implementing a scheduler, `<cwhip/Callbacks.h>` also exposes
the opaque `CwhipCallbackTransfer`:

```c
CwhipCallbackTransfer *transfer =
    cwhip_callback_transfer_prepare(callback, "callback<void()>");
/* Publish to the destination using package-owned synchronization. */
CwhipCallbackContext *context = cwhip_callback_transfer_accept(transfer);
/* The destination now owns context; transfer was consumed. */
```

Prepare validates the canonical signature and roots the callback/receiver
independently of the preparing thread's lifetime. Accept requires a registered
Cwhip thread holding the managed lock and creates a new registration owned by
that accepting thread. It consumes/frees the transfer, without any gap in root
protection. `cwhip_callback_transfer_cancel(transfer)` consumes/frees it without
invocation and removes its root. Prepare/accept/cancel all require the managed
lock; the package is responsible for queue publication, single consumption,
shutdown cleanup, and never using a consumed pointer. Transfers are not
invocable adapters and do not change the ownership of existing registrations.

`<cwhip/RuntimeGc.h>` provides `cwhip_runtime_managed_enter()` and
`cwhip_runtime_managed_leave(acquired)` for native callbacks on **already
registered** threads. Enter returns 1 if it acquires a suspended thread's lock,
0 if synchronous reentry already holds it. Leave restores that exact state.
Use strict `cwhip_runtime_gil_release()` / `cwhip_runtime_gil_acquire()` around
native blocking waits; never execute Cwhip or mutate managed data/roots while
suspended. The helpers neither register an unknown thread nor bypass callback
owner checks. See the GTK package for an actual scheduler and typed forwarding
implementation, not a generic permission to invoke from a foreign C thread.

**Exception policy: fail-fast.** Adapter entry installs an existing runtime
exception boundary inside the bridge. An exception escaping the Cwhip callback
is caught there, prints `Cwhip native callback error: uncaught Cwhip exception`
and its message/stack, and calls `abort()`. No `longjmp` or unwinding crosses the
calling C library's frames, no default native return value is fabricated, and an
outer Cwhip `except` cannot catch that boundary failure. Signature/lifetime/thread
violations likewise print a native callback error and abort. Exceptions caught
inside the callback behave normally. Use Cwhip code to handle recoverable
errors and return an explicit application-level error result.

The hermetic fixture in `tests/functional/cli/callbacks/native.c` demonstrates
actual compilation/linking, retention, disconnection, reentry, and rejected
foreign-thread invocation without GTK.
