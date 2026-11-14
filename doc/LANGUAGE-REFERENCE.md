# Cwhip language reference

Cwhip is the object-oriented language implemented by this repository's
compiler, invoked as `cwhip`. The name comes from the coachwhip, a fast,
nonvenomous snake; Cwhip aims to be a small, nimble compiler, and bug-eating is
a playful metaphor for the snake's prey and finding software bugs—not a
reference to goads, punishment, or violence. The compiler frontend is C++17
and the runtime is written in C. CPL and CWPL are optional informal shorthand.
The canonical project website is [cwhip.org](https://cwhip.org).
New source files use `.cw`; no alternate source suffix is accepted for
existing programs. The compiler produces textual LLVM IR and invokes Clang
to link the runtime. Fixed-width numeric types execute through width-correct
LLVM IR, checked integer operations, and IEEE floating arithmetic. This
repository's SDK and bundled standard-library packages use numeric-v2.
Applications and native modules built against an earlier SDK must be rebuilt,
and consumers using the removed `unsigned` type name must migrate their source.
`int`, `uint`, and `float` are native aliases for `int32`, `uint32`, and `fp32`.
External consumer repositories are not updated automatically. The separately
indexed historical language notes provide design context, not the current
language contract.

The parser limits recursive syntax nesting to 128 active levels, counting
namespaces, statement blocks, expressions, and unary operators. Excessive
nesting is a compile-time diagnostic, not a process crash. This protects the
recursive parser from malformed or adversarial inputs; ordinary programs
remain well below the limit.
Expression trees are also limited to depth 128, including flat operator/member
chains, to protect later recursive analysis and AST cleanup. Long shallow
collections are not restricted by this depth limit.

Grammar links below name productions in [GRAMMAR.md](GRAMMAR.md). Standard
library package APIs are intentionally covered separately in
[STDLIB.md](STDLIB.md).

## Lexical structure

Identifiers start with an ASCII letter or `_` and continue with letters,
digits, or `_`. Keywords are case-insensitive; identifiers are case-sensitive.
The exact identifier `String` names the built-in string class, while `strg` is
the primitive type keyword for string values. Lowercase `string` is an ordinary
identifier. `list` and `dict` are the collection type keywords; `array` and
`map` are ordinary identifiers. See `IDENT`,
`primitive-type`, and the lexical grammar.

Statements normally end at a newline. Braces delimit blocks; indentation is
for readability only. Newlines inside `()` and `[]` are ignored. `#` and `//`
start line comments; `/* ... */` comments can span lines but do not nestedly
pair. `;` is an unknown character, not a comment or statement separator.
See `NEWLINE`, `COMMENT`, and `terminator`.

Integer literals may be decimal or hexadecimal (`0x`/`0X` followed by
case-insensitive digits `0`-`9` and `a`-`f`). Unsuffixed literals use the
smallest fitting signed width; a trailing `u` or `U` selects the smallest
fitting unsigned width. Signs are unary operators, and a directly negated
literal can represent the signed minimum. Floating literals default to
`fp32`; an `f64` suffix selects `fp64`, and unsuffixed literals fall back to
`fp64` when they do not fit finite nonzero `fp32`. Out-of-range integer and
non-finite `fp64` literals are rejected.
Double-quoted and single-quoted strings are UTF-8 and cannot span physical
lines. Double quotes support `\e` (ESC, byte `0x1b`), `\n`, `\r`, `\t`,
`\\`, and `\"`; single quotes do not interpret escapes. See `INTEGER`,
`UNSIGNED_INT`, `FLOAT`, `STRING`, and `ESCAPE`.

`int`, `uint`, and `float` name the target C ABI's 32-bit signed integer,
unsigned integer, and binary32 float, and normalize to `int32`, `uint32`, and
`fp32`. The configured Clang target is checked for those widths and format.
`unsigned` remains reserved but is not a type alias. `float32` and `float64`
are not aliases.

## Program structure and entry point

A program has zero or more top-level imports and declarations, followed by
exactly one `start { ... }` block (`program`, `start-block`). The `start`
block is the executable entry point. `return(expr)` inside `start` (including
nested blocks, branches, and loops) ends the program; `expr` must have an
integer type and becomes the process exit status (the OS keeps the low 8 bits
on POSIX). A bare `return` exits with status 0. Enclosing `finally` blocks run
first, as for a method return. Falling off the end of `start` still exits 0, and
an unhandled `raise` is still an error exit. `System().exit(code)` (package
`system`) ends the program immediately from any point, including methods and
callbacks, without running `finally` blocks or other pending Cwhip code;
buffered C stdio output is flushed by the C runtime. A separately imported module may contain
declarations but no `start` (`module`). The compiler can also compile several
source files as one compilation unit, with exactly one `start` among them.

```cwhip
// Complete program: executable statements live in start.
// test: {"stdout": "Cwhip is running"}
start {
    print("Cwhip is running")
}
```

## Types and values

`R<P1,P2>` declares a bound-instance-method callable signature.
Capture with `object.method` (no invocation parentheses), then call the value
with `action(arguments)`. Callback locals, fields, parameters, and results
are supported with exact signature checking, contextual overload selection,
virtual dispatch, and receiver GC retention. Null/default, equality, unsupported
dynamic operations, and the installed C bridge are specified in
[Bound-method callbacks](CALLBACKS.md).

```cwhip
// test: {"stdout": "42"}
class Worker {
    public:
    int64 answer(int64 value) { return(value + 2)}
}
start {
    Worker worker = Worker()
    int64<int64> action = worker.answer
    print(action(40))
}
```

The numeric types are signed `int8`, `int16`, `int32`, and `int64`; unsigned
`uint8`, `uint16`, `uint32`, and `uint64`; and IEEE `fp32` and `fp64`.
Their shared semantic descriptor records category, width, signedness, range,
and LLVM representation. Other built-in types include:

| Type | Values and behavior |
|---|---|
| `bool` | `true` or `false`. Conditions must have this type; there is no general truthiness conversion. |
| `String` / `strg` | Managed UTF-8 string object. `strg` names the existing `String` class type. |
| `list` | Ordered, dynamically sized, heterogeneous collection. |
| `dict` | String-keyed collection with dynamically typed values. |
| `buffer` | Mutable sequence of bytes. |
| `range<T>` | Immutable inclusive integer interval, traversed in endpoint order; `T` is a fixed-width integer type. |
| `handle` | Opaque native/runtime handle with no built-in language operations. |
| `any` | Internal inferred type for dynamically tagged values, especially collection reads and loop values. It is not a user-declarable type. |
| `type` | Runtime type descriptor, produced by `type(value)` or a type name used as a value. |
| class name | Managed object reference, including `Exception` subclasses. |

Although `any` is a reserved token and an internal inferred type name, users
cannot declare `any` variables, fields, parameters, or return types. Collection
reads and list/dict foreach values are inferred as `any` internally; that does not make
`any` legal in a declaration. Such values can be inspected with `is` or
`type(...)`, printed, compared with `null`, and stored or passed where the
dynamic value is supported. To use a value in ordinary member access or
arithmetic, first extract it into a concrete typed local; extraction performs
a runtime type check and raises if the value has a different type. See
`primitive-type`, `type`, `return-type`, and `type-test-name`.

The parser also recognizes `void` as a method return type. It is not a
storable value type. See `primitive-type`, `type`, `return-type`, and
`type-test-name`.

The frontend classifies integer literals to the smallest fitting signed or
unsigned type. Integer arithmetic uses the smallest common type that safely
contains both ranges; mixed signed/unsigned operations with no common type
(notably `int64` and `uint64`) are rejected. Integer comparisons support every
integer pair without converting through a lossy common representation.
Floating arithmetic promotes to the wider floating type; integer/floating
arithmetic uses `fp32` only when it can exactly represent the integer type's
full range, otherwise `fp64`. Assignment, argument, and return conversions
use the same range/precision model. Potentially lossy implicit conversions
produce a warning with an explicit-cast suggestion; explicit casts acknowledge
that loss.

Signed addition, subtraction, multiplication, and negation throw catchable
exceptions on overflow at the expression's result width. Assignment does not
widen an intermediate: `int32 value = int8(127) + int8(1)` throws. Unsigned
arithmetic wraps modulo the result width. Integer division truncates toward
zero, and remainder has the dividend's sign. Division/remainder by zero and
signed minimum divided or remaindered by `-1` throw before LLVM can evaluate
an invalid operation. Failures carry operation/source information.

Bitwise operations use fixed-width integer patterns and the normal common
integer type. `~` preserves type. Shifts retain the left type and validate the
original right operand before conversion: negative counts or counts at least
the left width throw. Left shift discards high bits, even for signed operands;
right shift is arithmetic for signed and logical for unsigned operands.
Compound assignments evaluate their receiver/target once, then convert the
result back to the target type.

`fp32`/`fp64` operations round at their selected precision, nearest/ties-to-even,
with signed zero, gradual underflow, infinities, and unordered NaN comparisons.
Floating overflow and division by zero do not throw integer exceptions.
Constrained LLVM arithmetic prevents reassociation and multiply/add contraction;
there is no implicit fast math. The execution environment must retain IEEE
rounding and subnormals. Native code that changes that environment must restore
it before returning to Cwhip.

Explicit numeric casts use the numeric type-name call forms such as
`int8(expr)`, `uint64(expr)`, and `fp32(expr)`. Integer conversions reduce modulo
the destination width, with sign extension before widening a negative source.
For example, `int8(255)` is `-1` and `uint16(int8(-1))` is `65535`.
Integer-to-floating and floating narrowing round to the destination IEEE
format; floating narrowing may produce infinity or signed zero.
Floating-to-integer conversions truncate first, then range-check: `uint8(-0.75)`
is `0`, while `uint8(-1.0)`, NaN, infinity, and out-of-range results throw.
Explicit casts acknowledge loss, not invalid conversions. Explicit bool casts
map zero to false and other numeric values, including NaN, to true.
Compatible class-reference conversions and dynamic collection extraction
remain separate behaviors.

Numeric arguments, returns, fields, callbacks, inline captures, and dynamic
values preserve their actual widths. Native bindings use exact-width C integer
types and `float`/`double`, including target ABI extension attributes for narrow
values. Native execution coverage currently exercises the Linux x86-64 ABI.
Inline C retains C arithmetic semantics, not Cwhip overflow checking.

`null` is a universal null value and can initialize nullable numeric locals.
An explicit numeric cast consumes a local's null state using its zero payload.
Null assignment does not make
primitive fields, collection values, arguments, or returns nullable in the
same way: those contexts retain their declared representation. Object and
reference values can be null. Use `is Type` to inspect a value's dynamic type;
`type(value)` returns its type descriptor. See `type-test-name`, `primary`,
and `relational`.

```cwhip
// Complete program: null locals, casts, and runtime type tests.
// test: {"stdout": "no integer value"}
start {
    int64 maybe = null
    if (maybe is int64) {
        print(maybe)
    } else {
        print("no integer value")
    }
}
```

## Variables and scope

Declare a local with `type name`. Class-typed locals may be constructed
directly with `ClassName name(arguments)`, including `ClassName name()` for
the zero-argument constructor. This form selects the matching constructor
using the usual overload, type, and access checks. Built-in types do not use
this syntax. The existing `type name = expression` form remains supported,
including constructor expressions such as `Base item = Derived()`; constructor
expressions also remain valid in returns, call arguments, and other expression
contexts. Locals are block-scoped and may be initialized later. An inner
declaration shadows an outer binding; assignments to the inner variable do not
change the outer one, and shadowing currently emits no warning. Redeclaring a
name in the same scope is an error. The compiler diagnoses a read that may
occur before initialization. Parameters and fields are introduced by their
declarations; fields may use
[compile-time constant initializers](#compile-time-field-initializers), and `for`
loop variables exist only in the loop body. Assignment operators are statements,
not expressions. `=` assigns normally; arithmetic, bitwise, and shift compound
assignments update numeric variables or object fields using the corresponding
operation and conversion back to the target type.
Operands follow the normal common-type rules; `%=` and bitwise/shift forms
require integers. Collection/buffer references, `any`, booleans, and object
references and indexed elements do not support compound assignment.
A compound assignment evaluates
its target once; for a member target, its receiver is evaluated once. Integer
overflow and integer division/remainder errors follow the corresponding
arithmetic operators.

```cwhip
// Complete program: an inner value shadows, rather than changes, the outer value.
// test: {"stdout": "340"}
start {
    int64 value = 40
    {
        int64 value = 2
        value = value + 1
        print(value)
    }
    print(value)
}
```

This writes `340`; `print` does not add line breaks.

A local declaration may start with `const`: `const type name`,
`const type name = expression`, or `const ClassName name(arguments)`.
`const` is a case-insensitive reserved word, so it cannot be used as a name.
It applies to locals in `start`, methods, constructors, and destructors.
Fields, parameters, and enum constants do not use it. A field is not declared
`const`, a parameter already has a value, and assigning to an enum constant
remains a compile-time error.

A `const` local accepts one value. An initializer, including a direct
constructor call, is that value. A declaration with no initializer has no
value yet, and the zero or null fill stored for the slot does not count.
The first later assignment stores the value. Another assignment to that
variable, including a compound assignment, raises a catchable exception.
The check is dynamic: a store in one branch makes a later store fail only
when that branch ran. Reading the variable before any store is still the
compile-time error `variable '…' may be uninitialized`.

`const` tracks stores to the variable itself. Indexing a `const` list, dict,
or buffer, and calling a method that updates a `const` object's fields,
changes the referent. Reseating the variable does not. An `inline` C capture
of a `const` local is rejected, because the capture would expose the slot to
stores that bypass the check.

```cwhip
// Complete program: a const local keeps its first value.
// test: {"stdout": "1kept1"}
start {
    const int64 value = 1
    print(value)
    try {
        value = 2
    } except() as error {
        print("kept")
    }
    print(value)
}
```

## Expressions and operators

Expressions include literals, names, parentheses, list, dict, and buffer
literals, casts, `type(value)`, `buffer(length)`, class construction, method calls,
member access, indexing, slicing, and type tests. Calls are written as
`ClassName(arguments)` for construction or `object.method(arguments)` for
methods. The parser does not support free functions, closures, or arbitrary
callable-valued expressions. See `expression`, `primary`, `postfix`, and
`constructor-declaration`.

Operators from lowest to highest precedence:

| Operators | Associativity |
|---|---|
| `or`, `\|\|` | left |
| `and`, `&&` | left |
| `not`, `!` | right prefix |
| `==`, `!=` | left |
| `is`, `in`, `<`, `<=`, `>`, `>=` | left |
| `..` | non-associative |
| `\|` | left |
| `^` | left |
| `&` | left |
| `<<`, `>>` | left |
| `+`, `-` | left |
| `*`, `/`, `%` | left |
| unary `+`, unary `-`, `~` | right prefix |
| `.`, calls, `[]` indexing/slicing, `as` checked extraction | repeated postfix |

Logical operators require booleans. Arithmetic and comparison support depend
on operand types; unsupported combinations are rejected during semantic
analysis. Bitwise/shift operands must be integers, not bool or floating values.
Bitwise operations bind more tightly than comparisons and range construction;
parenthesize mixed expressions when needed to make the intended grouping clear.
Assignment is not an expression. There are no increment or ternary operators.

### Checked extraction with `as`

`value as Target` is checked extraction/identity, not a numeric conversion.
Targets include every fixed-width numeric type, `bool`, `strg` (also spelled `String`),
`list`, `dict`, `buffer`, `handle`, `type`, `null`, `any`, or a declared class
(including a qualified class name). `void` and unknown names are compile-time
errors. The source is evaluated exactly once.

An internal `any` source, such as a list or dict read or foreach value, is
checked against the requested dynamic tag. Scalars and type descriptors require
the exact matching tag; `strg`/`String` requires a String object; list, dict,
buffer, and handle targets require their respective reference tags; class
targets accept the exact class or a subclass.
Class extraction adjusts to the requested unique base subobject, including
secondary and virtual bases. Ambiguous repeated nonvirtual bases and all
mismatches raise catchable, source-located runtime exceptions. Use `is` to
inspect mixed bags without raising on a mismatch.

Statically known sources may be extracted identically; class references may
also be checked against another class target. Other statically impossible
source/target pairs are rejected during semantic analysis. `as any` boxes a
statically typed supported value, or preserves an existing `any`; the `null` literal boxes as the dynamic null value. `as null` checks
for a null pointer in a reference payload (class/String, list, dict, buffer,
or handle) or a dynamic null. It does not recognize null-valued scalar slots
or type descriptors.

Null extraction follows the existing typed-extraction representation:
Class/String extraction preserves the canonical dynamic null payload.
`buffer` extraction accepts that canonical null tag; `handle` extraction
accepts it and also accepts a null pointer carrying the handle tag. `list` and
`dict` extraction require their matching tag and a non-null collection
reference. Scalar and `type` targets require their exact tags and therefore
reject null. Statically typed same-type expressions remain identity
operations and preserve their existing nullable value. No new
nullable-scalar behavior is introduced.

Use `(items[index] as Foo).method()` for member calls without a temporary
local. Qualified targets work, for example
`(mapping["item"] as model.Foo).method()`. Casts bind at postfix precedence.
`Foo(value)` remains construction, never a cast. Scalar conversions use
`bool(value)` or an exact numeric destination, such as `int8(value)`,
`uint64(value)`, or `fp32(value)`.

Literal text can be formatted with the `format` intrinsic and positional
arguments, such as `format("value: {}", value)`, or with named arguments, such as
`format("user {name} has {count} messages", count=total, name=user)`. Named arguments
bind case-sensitively to placeholder names regardless of argument order.
Each distinct placeholder needs exactly one named argument; a name may be
referenced repeatedly, and its argument expression is evaluated once.
Positional `{}` and named `{name}` forms cannot be mixed in one format call.
Use `{{` and `}}` for literal braces. Formatting is not automatic
interpolation. Arguments support the same printable scalar, string, type, and
dynamic values as positional formatting. `format` returns a fresh managed `strg`,
usable anywhere an expression is accepted. Templates must be string literals
(either quote style); dynamic templates are not supported. Arguments are
evaluated and snapshotted once, left-to-right, before assembling the result.
The old string-literal-call syntax is rejected, not an alias.

`print(value)` retains scalar/string/type/dynamic printing. `print("literal")`
prints the literal unchanged, including braces. `print("value: {}", value)`
formats with the same rules as `format`, then writes the completed result
without adding a newline; formatting failure emits no partial output.

An optional `:` introduces this deliberately limited, C++20-inspired subset,
not full `std::format` compatibility:

| Specifier | Meaning |
|---|---|
| `d` | Decimal integer of any signed or unsigned width |
| `x`, `X` | Lower-/upper-case hexadecimal, without prefix; negative signed values use sign plus magnitude |
| `c` | One ASCII byte from an integral value in 0..127, including NUL |
| Width | Minimum field width, at most 1000000; never truncates |
| `<`, `>`, `^` before width | Left, right, or center space padding; an odd center-padding remainder goes on the right |
| Leading `0` before width | Numeric zero padding after the minus sign; integral values only; incompatible with explicit alignment and `c` |

The order is `[alignment][width][type]`, for example `{:x}`, `{:08X}`,
`{:c}`, `{:>8}`, or `{value:08X}`. Empty specs retain default rendering.
Default alignment is right for numeric values and left otherwise. Width counts
Unicode code points, not bytes or terminal display columns. Floating-point
precision, custom fill characters, positional indices, and other type codes
are unsupported. Explicit type codes require an integer type; statically
known incompatible types and malformed templates are compile-time errors.
Dynamic type mismatches and ASCII range violations raise catchable exceptions
located at the argument expression. Negative values and 128+ never generate
invalid UTF-8. See `format-expression` and `print-statement` in the grammar.

```cwhip
// Complete program: arithmetic, logical operators, and formatting.
// test: {"stdout": "answer=42"}
start {
    int64 first = 20
    int64 second = 22
    bool ready = first > 0 and second > 0
    if (ready) {
        print(format("answer={}", first + second))
    }
}
```

## Statements

The supported statements are local declarations, assignment, method-call
expression statements, `print`, nested blocks, `if`/`else`, `while`,
`do`/`while`, `for`-each, `break`, `continue`, `switch`/`case`/`next`, `return`,
`try`/`except`/`finally`, `raise`, base-constructor initializers, and inline C.
See `statement` and its named productions.

Conditions are parenthesized and must be `bool`. An `else (condition)` clause
continues an `if` chain: conditions are evaluated lazily in source order, and
only the first true branch executes. Any number of conditional `else` clauses
may precede one optional, final bare `else`. Each clause requires a block;
`else if` and `else ()` are not supported. Newlines may separate `}` from `else`
or a condition from its block, but not `else` from its opening `(`.

```cwhip
# Complete program: conditional alternatives and parenthesized return values.
// test: {"stdout": "less\n"}
class Comparison {
    public:
    strg describe(int left, int right) {
        if (left == right) {
            return("equal")
        }
        else (left > right) {
            return("greater")
        }
        else {
            return("less")
        }
    }
}
start {
    Comparison comparison()
    print("{}\n", comparison.describe(1, 2))
}
```

The `do` body executes at least once.
`for (value in collection)` iterates list values; `for (key, value in dict)`
iterates dict keys and values. The value variable has type `any`; the key
variable has type `String`. `break` and `continue` are valid only in loops.
They cannot cross a switch branch boundary to reach an outer loop.
`for (i in bounds)` also accepts [integer ranges](#integer-ranges), binding
a read-only integer of the range's endpoint type rather than `any`.

```cwhip
// Complete program: while, continue, and for-each.
// test: {"stdout": "6"}
start {
    list values = [2, 3, 4]
    int64 total = 0
    for (value in values) {
        if (value is int8) {
            int8 number = value
            if (number == 3) {
                continue
            }
            total = total + number
        }
    }
    print(total)
}
```

### Constant switches

`switch (selector) { ... }` evaluates its selector exactly once. The selector
must have an integer type (`int8` through `uint64`); class enum members are
supported because they are `int64` constants. `bool`, floating-point, strings,
and objects are not switch selector types.

Each `case (values) { ... }` requires parentheses and braces. Values are
compile-time integer expressions, including enum references, integer arithmetic,
bitwise operations, and explicit numeric casts. Enum references in labels must
be unqualified constants in a method or qualified through a class name, not
through a runtime instance expression. Separate alternatives with
commas; `low..high` denotes an inclusive range and can be mixed with individual
values. Either endpoint order is accepted: `1..3` and `3..1` match the same
inclusive set. Groups such as `case (1..3, 5..8)` and `case (3..1, 5..8, 10)`
are supported. Endpoints may reference constants from different classes.
Ranges are tested without enumerating their elements, even across the
full `uint64` domain. Every evaluated value/endpoint must be losslessly
representable in the selector type; there is no implicit narrowing or modular
conversion to make a label fit. Explicit casts and constant arithmetic retain
the ordinary numeric rules (for example, `uint8(255) + uint8(1)` is zero).
Duplicate or overlapping labels are compile-time errors after endpoint
normalization, including equal signed/unsigned constants.

Ordinary branch completion exits the switch: there is no implicit fallthrough
and no switch `break`. An optional `default { ... }` has no parentheses, may
appear only once, and must be last. With no matching label and no default,
execution continues after the switch. Empty switches are valid.

```cwhip
// Complete program: alternatives, inclusive ranges, and explicit continuation.
// test: {"stdout": "prepare/process/other"}
start {
    int64 value = 1
    switch (value) {
        case (1) {
            print("prepare/")
            next
        }
        case (2, 4, 6, 10..20) {
            print("process/")
            next
        }
        default {
            print("other")
        }
    }
}
```

`next` unconditionally executes the immediately following branch **body**,
without checking its labels (including a following `default`). It must be the
final direct statement in a branch with a following branch. A `next` inside
an `if`, nested block, loop, or exception block is rejected; nested switches
may have their own `next`. Each branch has a separate lexical scope, so a
local declared before `next` is not visible in the following branch. Completed
`try` blocks run their `finally` before the transfer. Object lifetimes retain
the normal managed/explicit-destruction rules; `next` adds no automatic
destruction.

Case boundaries prevent `break` and `continue` from escaping to a loop outside
the branch. Loops declared inside a branch still permit their own `break` and
`continue`. A `return` exits the enclosing method, not just the switch, with
normal exception/finally cleanup. As with other control-flow constructs,
definite initialization is conservative: a later branch must be valid when
entered directly, not only via `next`.

`switch`, `case`, and `default` are case-insensitive reserved words. `next` is
contextual only when it forms a standalone statement, preserving existing
identifiers such as `Process.next()`, a local named `next`, or enum member `NEXT`.
Newlines delimit simple statements; `#` and `//` start comments. A semicolon
is not a comment introducer or statement separator.

## Classes, objects, inheritance, and dispatch

Classes contain fields and methods. Member access is `private` by default:
a member with no preceding `public:` or `protected:` is private. `public:`
and `protected:` opt in for the members that follow, and that section stays
in effect until the next access marker. Namespaces and modules have no
access sections of their own; a class declared in either place uses this
same member default.
Fields may use compile-time constant initializers; see
[Compile-time field initializers](#compile-time-field-initializers). A
constructor is named after its class, omits the return type (write `Name(...)`,
not `void Name(...)`), and
can be overloaded. A class-body method named after its class with any return
type is rejected rather than treated as an ordinary method. A destructor is written `destroy { ... }` inside
the class; it has no return-type or parameter list. Methods can be defined in
the class body or declared there and defined out of line. See
`class-declaration`, `class-member`, `constructor-declaration`,
`destructor-declaration`, `method-declaration`, and
`out-of-line-definition`.

### Compile-time field initializers

Fields may be initialized with a compile-time constant expression:

```cwhip
class Settings {
    public:
    enum { BASE = 40 }
    int64 count = BASE + 2
    strg label = "ready"
    dict options = ["limit": 3]
}
```

Supported initializers include numeric, boolean, string, null, and type
descriptor literals; accessible enum members (unqualified in the owning or an
inherited class, or class-qualified); constant scalar casts; folded numeric
arithmetic, bitwise and shift operations; boolean logical operations and
numeric comparisons; and constant list, dict, and buffer literal trees. Each
object receives fresh mutable collection and string storage. Calls,
construction expressions, instance fields, and instance-qualified enum reads
are rejected with `field initializer must be a compile-time constant`.
Integer overflow, division by zero, and invalid conversions produce the
required-constant diagnostics.

Allocation still zero/null-initializes fields without explicit initializers.
Then all declared and inherited field initializers run for the complete object
before any constructor body, including base-constructor bodies and virtual
dispatch from those bodies. Each nonvirtual base subobject has its own defaults;
a shared virtual base is initialized once. Calling a base constructor does not
reset field initializers or writes made by an earlier constructor. Constructors
may overwrite defaults. These rules apply to classes without constructors,
overloads and out-of-line constructors, and allocations made in expressions,
locals, returns, arguments, loops, and automatic virtual-base construction.
Explicit-super ordering requirements are unchanged. Scalar fields remain
unboxed: an explicit `null` initializer stores zero or `false` for numeric and
boolean fields, rather than making those fields nullable.

An anonymous class-scoped enum block declares immutable signed 64-bit `int64`
constants, not an enum type:

```cwhip
class Status {
    // test: {"stdout": "12"}
    public:
    enum {
        READY = 10,
        RUNNING,
        COMPLETE = READY + 2,
    }
}

start {
    Status status = Status()
    int64 code = status.RUNNING
    print(Status.COMPLETE)
}
```

The first omitted value in each block is `0`; each later omitted value is the
preceding value plus one. Explicit values may use integer literals, unary
`+`/`-`/`~`, arithmetic, bitwise operations, shifts, numeric casts, and previously
resolved enum members. Each intermediate follows its ordinary numeric type,
including narrow signed overflow, unsigned wrapping, and IEEE rounding within
casts. The final value must fit `int64`. Implicit increments are checked too;
duplicate numeric values are allowed, but duplicate names and class-member
collisions are errors. Forward/cyclic references, nonconstant expressions,
division by zero, and out-of-range values are compile-time errors. Multiple
blocks may appear in one class, with distinct member names.

Invalid operations in these required constant contexts are compile-time
diagnostics. Ordinary expressions are not evaluated by this evaluator:
constant-looking overflow, bad shifts, and invalid conversions still raise
catchable runtime exceptions; unreachable branches do not acquire execution
errors during compilation. Literal range/syntax errors remain compile-time
diagnostics. Zero list-slice steps are likewise checked at runtime.

Constants are usable anywhere an `int64` expression is accepted, including
method arguments, collection values, and scalar casts. They follow the
declaring member's public/protected/private access and ordinary inherited
member lookup; ambiguous inherited constants need explicit base qualification.
Use either `object.NAME` or `Class.NAME`, including namespace-qualified class
names. Instance-qualified access resolves from the static class and does not
dereference or null-check the receiver, but a receiver expression with side
effects is still evaluated exactly once. Constants have no runtime allocation
or per-instance storage. Assignment, compound assignment, and inline field
captures are rejected; copy the constant into a local before modifying or
capturing it.

Inheritance uses a colon and one or more comma-separated base specifiers.
Each base defaults to public access. `public`, `protected`, or `private`
controls the inheritance path; `virtual` may also mark a base. Multiple
inheritance, virtual bases, and base-qualified member access are implemented.
Ambiguous inherited fields/methods must be qualified through a base.
Constructors initialize direct bases with `super Base(args)` as leading
statements. Virtual bases use either `super virtual Base(args)` or
`virtual super Base(args)`; the two forms have identical semantics. A dot is
not allowed between these keywords or the base name. Virtual inheritance is
distinct from virtual method dispatch: it shares a base subobject across
inheritance paths, while virtual method dispatch selects an override at
runtime. A non-virtual base is a separate subobject on each path.

Only the most-derived constructor initializes the complete object's virtual
bases. Every class that has virtual bases may declare `super virtual Base(...)`,
even when it is also used as a base class, and may be constructed directly.
When that constructor runs for a base subobject, its virtual-base initializers
are skipped and their argument expressions are not evaluated. The
most-derived constructor initializes each virtual base once; if it omits an
initializer, that base's zero-argument constructor runs automatically. If the
base has no zero-argument constructor, constructing the most-derived class
without an explicit initializer is a compile-time error. Virtual bases are
constructed before direct non-virtual bases in depth-first, left-to-right
virtual-base order, with virtual ancestors before their descendants. A shared
virtual base is destroyed once, after non-virtual bases, in reverse virtual
construction order; repeated non-virtual base subobjects are each destroyed
separately.

A derived class may override an inherited method with a compatible signature.
Calls use the runtime object's method dispatch; there is no separate `virtual`
method modifier.

A constructor may instead begin with a single `try` whose body consists only
of its base initializers. Required direct bases must still be initialized
exactly once in declared order; explicit virtual initializers precede them
in virtual-base construction order and only initialize virtual bases when this
constructor is running for the complete object.
Automatic default virtual-base initialization also runs inside this `try`.
Every `except` handler must raise or rethrow on every path (nested blocks,
`if`/`else`, and `try` are supported); any `return`, including a nested or
unreachable return, is rejected. A loop alone is not proof of exceptional
termination. Optional `finally` uses the normal exception cleanup rules.
Handlers cannot recover a failed initialization: the constructor cannot
continue or return a successfully constructed partial object. No destructor
or finalizer runs for the failed allocation. `raise()` retains the original
exception object, raise location, and stack trace; a replacement `raise`
creates a new exception. Initializers in handlers, cleanup, branches, loops,
later statements, or mixed direct/protected sequences are rejected.

```cwhip
class Foo {
    // test: {"stdout": "caught the first timethis is the stringcaught the second time"}
    public:
    Foo() { raise(Exception("this is the string")) }
}
class Bar : Foo {
    public:
    Bar() {
        try { super Foo() }
        except() {
            print("caught the first time")
            raise()
        }
    }
}
start {
    try { Bar b() }
    except() as e {
        print(e)
        print("caught the second time")
    }
}
```

```cwhip
// Complete program: inheritance, construction, override, and dispatch.
// test: {"stdout": "42"}
class Meter {
    public:
    int64 value
    Meter(int64 initial) {
        value = initial
    }
    int64 read() {
        return(value)
    }
}

class AdjustedMeter : public Meter {
    public:
    AdjustedMeter(int64 initial) {
        super Meter(initial)
    }
    int64 read() {
        return(value + 1)
    }
}

start {
    Meter meter = AdjustedMeter(41)
    print(meter.read())
}
```

The above is a complete program. Base-qualified member access uses an object
and a base path (for example, `object.Base.field`, `object.Base.method()`, or
`object.Left.Root.field`). Inside a method, constructor, or destructor body,
the receiver may be omitted: `Base.field` and `Base.method(args)` refer to the
current object's base subobject, not static or class-level storage.
`Left.Root.field` and `Left.Root.method(args)` select successive direct bases;
the path cannot skip an inheritance edge. Reads, assignments, and supported
numeric compound assignments use the same base
layout and accessibility rules as explicit-object access. Method calls retain
runtime dispatch, just like `object.Base.method()`; qualification selects a
base view, not a non-virtual call.

A local variable or parameter takes precedence over a field, and a field takes
precedence over an implicit base qualifier, even if its name matches a base.
Thus `Base.field` uses an ordinary object receiver when `Base` names a variable
or field; it does not fall back to base qualification if that receiver is
invalid or ambiguous. Otherwise, the initial class name is resolved using the
normal lexical namespace/import-alias rules and must name a direct base.
Both `Base.field` and `Namespace.Base.field` can supply that initial class name.
Subsequent base steps follow the existing explicit-object base-path rules.
Type-valued contexts and qualified class construction retain their existing
name resolution; `Namespace.Class()` still constructs an object when its
receiver prefix is not an applicable implicit base.

Private inheritance permits access from the class declaring that inheritance
but not from outside it or further derived classes. Base-private members
remain inaccessible; protected members follow the ordinary derived-class
access rules. Ambiguous unqualified members remain errors. This syntax does
not enable `Base.field` or `Base.method()` outside an applicable class body.

A `super` base initializer is only for constructor initialization and must
appear before ordinary constructor statements. Field visibility uses sections
such as `public:` followed by separate field declarations, not inline
`public int64 field` declarations.

Explicit `object.destroy()` invokes the destructor but does not immediately
reclaim the object's storage, and no compiler warning is emitted. The call
still uses parentheses; only the in-class definition omits them. The object
is marked destroyed before the destructor runs; a repeated destruction call
or later use of the object raises a catchable runtime exception. Destructors
cannot be defined out of line. See `super-initializer` and `postfix`.

## Namespaces

Namespaces group classes and can nest or reopen. A class's namespace prefix
is used when resolving its type and base names. `start`, `import`, and
`include` cannot be declared within a namespace. Out-of-line definitions must
be in the same namespace scope as the class they define. See
`namespace-declaration` and `namespace-item`.

```cwhip
// Complete program: a class in a namespace.
// test: {"stdout": "7"}
namespace Geometry {
    class Point {
        public:
        int64 x
        Point(int64 value) {
            x = value
        }
        int64 coordinate() {
            return(x)
        }
    }
}

start {
    Geometry.Point point(7)
    print(point.coordinate())
}
```

## Imports, packages, and textual inclusion

`import Name` resolves a package and exposes its declared exported namespace
(or exported class) under the export's own name. For example, `import system`
exposes `System.Process`, `System.File`, and `System.System`; it does not guess
a namespace from the lowercase package identifier. `import Name as Alias`
makes that same export available through the alias:
the alias replaces the package's namespace prefix. For example,
`import time as T` exposes `Clock` as `T.Clock`, not `T.Time.Clock`.
Standard-library classes are instance-based: construct the class before
calling an instance method, as in `Sys.Process().exit(0)`, rather than using
a static-style call such as `Sys.Process.exit(0)`.
Imports are top-level only and imported module source cannot define `start`.
Duplicate bindings, conflicts with local declarations, and namespaces shared
by different packages are diagnosed; use explicit aliases to choose local
binding names (aliases do not make conflicting package definitions compatible).
The `String` prelude remains implicit and does not need an import.
Package manifests are documented in [PACKAGES.md](PACKAGES.md) and package
APIs in [STDLIB.md](STDLIB.md).

New projects use the direct dependency manifest `cwhip-pkg.toml` and the generated
exact graph `cwhip-pkg.lock`. `cwhip-pkg add OWNER/REPO --yes` resolves and installs
the full graph; compilation then needs no environment activation and never
fetches code. Compilation validates lock freshness, exact dependencies, and
package integrity. The lock is discovered from the source project's root and
cannot be relocated by package storage overrides. See
[project module search](INSTALLATION.md#project-module-search) for the ordered
CLI, project, environment, user, and installation package roots. The legacy
`modules.toml`, tab-separated registry, `--package-path`, and
`CWHIP_PACKAGE_PATH` lookup mechanisms are no longer supported.
See `import-declaration` and `module`.

`include "relative/path.cw"` textually inserts source before parsing.
include paths remain valid for existing code. It is
only allowed before the top-level `start`; the including file's directory is
searched first, followed by configured include paths. Each canonical file is
included once, and included files cannot define `start`. Unlike imports,
includes do not create an isolated module namespace. See
`include-directive` and the source-loader notes in [GRAMMAR.md](GRAMMAR.md).

```cwhip
// Complete program (requires an installed/bundled `system` package).
// test: {"stdout": ""}
import system
start {
    System.Process().exit(0)
}
```

```cwhip
// Fragment (include is expanded before parsing):
include "shared/definitions.cw"
start {
    print("included source participates in this compilation unit")
}
```

## Exceptions

`Exception` is a built-in base class with a public `message` field.
`raise(expression)` raises an instance of `Exception` or a subclass; raise
arguments are parenthesized. Bare `raise` and `raise()` rethrow the active
exception.
Handlers use `except(Type)` for a typed catch, `except() as name` for a
catch-all whose binding is a `String` message, or `except(Type) as name` for
an exception-object binding. Both rethrow forms are valid only inside a
handler. `finally` runs for normal completion and
exception propagation. A `try` needs at least one `except` or a
`finally`; a catch-all must be last. A method may return from any executable
statement, including nested blocks, branches, loops, and exception handlers.
Returning runs enclosing `finally` blocks from innermost to outermost before
leaving the method. A return inside `finally` (even in a nested statement)
is invalid. A non-void method must return a value or raise on every reachable
path; loops alone do not guarantee this. See `try-statement` and
`raise-statement`. Constructors and destructors remain void-only, and `start`
still cannot return. Non-void return values use `return(expression)`; bare
`return` and `return()` are void returns.

```cwhip
// Complete program: raising and catching a typed exception.
// test: {"stdout": "brokenfinished"}
class Problem : public Exception {
    public:
    Problem(String text) {
        super Exception(text)
    }
}

start {
    try {
        raise(Problem("broken"))
    } except(Problem) as problem {
        print(problem.message)
    } finally {
        print("finished")
    }
}
```

## Integer ranges

For small runnable programs and their expected output, see
[the switches and ranges walkthrough](EXAMPLES.md#switches-and-integer-ranges).

`first..last` forms a first-class `range<T>`, not a list or a syntax-only loop
construct. Both endpoints are inclusive. Ascending iteration steps by `+1`;
descending iteration steps by `-1`. Membership ignores direction. A singleton
such as `4..4` visits `4` once. **Every formed integer range is nonempty**:
`0..-1` visits `0, -1`, not zero items. For index traversal, guard `count > 0`
before constructing `0..count-1`, or iterate the collection directly.

Endpoints are integer expressions evaluated **once, left to right**, when the
range is formed. The values are captured, not live variable references.
Changing either original variable is a normal write: it neither changes an
existing range nor raises an error. A newly formed range sees the new values.

```cwhip
// Complete program: parameters, storage, return values, snapshots, and slicing.
// test: {"stdout": "123/100/true/false/100true/dcb"}
class Worker {
    public:
    range<int64> processRange(range<int64> values) { return(values)}
}
start {
    Worker worker = Worker()
    int64 first = 1
    int64 last = 3
    range<int64> saved = worker.processRange(first..last)
    for (i in saved) {
        print(i)
        last = 100 // This write does not extend the loop.
    }
    print("/{}/{}/{}/", last, 2 in saved, 100 in saved)
    range<int64> updated = last..last
    for (i in updated) { print(i) }
    list stored = [saved]
    range<int64> restored = stored[0]
    print(2 in restored)
    strg text = "abcd"
    print("/")
    print(text[3..1])
}
```

`T` is the existing lossless common integer type of the two endpoint types.
For example, `int8(-1)..uint8(255)` has type `range<int16>`. Small unsuffixed
literal endpoints infer small types: `1..3` is `range<int8>`.
Locals, fields, parameters, returns, callbacks, and overloads accept
`range<int8>` through `range<uint64>`. Assigning/passing a range can widen its
endpoint type losslessly (so `range<int64> r = 1..3` is valid), but cannot
narrow it implicitly. Mixing any signed endpoint type with `uint64` has no
lossless common type and requires explicit endpoint conversion, even when the
current values happen to be small. Float, bool, object, null, and range
endpoints are rejected; an explicit valid integer conversion may be used
where appropriate.

The loop binding has type `T` and is read-only, including compound writes and
mutable inline captures. Copy it to a local before changing it. It has normal
lexical scope, with nested shadowing permitted. `break`, `continue`, return,
and exception/finally cleanup behave as in other loops. Iteration checks the
final endpoint before advancing, including at `int64` minimum and `uint64`
maximum. Iteration and membership use constant-size range storage, not a
materialized list. Iterating a huge range still takes time proportional to
the number of visited integers.
This does not provide a full-domain count/length API or make a loop-body
accumulator overflow-safe. There are no public endpoint accessors; use
printing/formatting or the debugger to inspect captured bounds.

`value in bounds` requires an integer value and a range. Integer comparison is
exact across widths and signedness: a negative signed integer is not in
`uint64(0)..uint64(18446744073709551615u)`. `..` binds less tightly than shifts
and arithmetic and more tightly than `in` and comparisons, so
`value in lower + 1..upper - 1` has the expected endpoints. Parenthesize
bitwise endpoint expressions. `1..2..3` is invalid.

Range values may be copied, reassigned, returned, and stored in lists/dicts.
Payloads are immutable; copies can share the captured interval safely.
`type(r)` and `r is range<int64>` expose the exact endpoint type. Collection
extraction and `as range<int64>` check that exact type, rather than silently
widening a dynamically tagged value; extract its actual type first to widen
it. Printing or default formatting displays `first..last`. Range-to-range
equality and custom strides are not implemented. A nullable range reference
can hold `null`, but using it for iteration, membership, or slicing raises a
catchable error; null is not an empty range.

### Inclusive copy slices

`items[first..last]` and `items[bounds]` accept range values for lists, Strings,
and buffers. Endpoints are inclusive, and the normalized endpoint order
controls traversal, so `"abcd"[3..1]` produces `"dcb"`. Both endpoints must
identify existing elements; there is **no clamping**. Existing indexing rules
apply: negative indices are relative to length (`-1` means the last element).
Indices outside the collection, including `uint64` values too large to index
it, raise a source-located catchable exception. Empty collections have no valid
range slice, including `0..0`.

The result has independent outer storage. List elements keep their ordinary
reference semantics: referenced objects or nested collections are shared,
not deep-cloned. Buffers and Strings copy their bytes. Slice assignment and
views are not supported.

String indices remain **UTF-8 byte offsets**, not code points or grapheme
clusters. The selected byte sequence must be valid UTF-8, or slicing raises a
catchable exception. For example, `"aéz"[1..2]` selects the two-byte `é`,
whereas `[1..1]` splits it, and reversing its bytes is invalid. Reverse ASCII
slices work normally; this feature does not add Unicode-aware reversal.

`list[start:end:step]`, `buffer[start:end]`, and dict insertion-order slices
stay half-open and clamped. String has no colon slice. A nonempty half-open
`slice(first, last)` is the inclusive range `first..last - 1`. An empty
half-open slice has no range spelling, because every formed range is
nonempty. Dicts have no range-index slices. Switch case labels retain
their separate compile-time integer restrictions, grouping, and
direction-independent interval matching; a stored range cannot be a label.

## Strings and their methods

String literals construct managed `String` values. Strings expose a
read-only `length` member (the UTF-8 byte length). `text[index]` reads one
byte as `uint8`. A negative index counts back from the length, and an index
outside the string raises. `text[index] = value` replaces that one byte when
the existing byte and the new integer are both in `0..127` and both edges of
the byte are UTF-8 boundaries. Any other write raises, so assignment cannot
split a character. `insert(index, text)`, `remove(first..last)`, and
`clear()` mutate the same storage, including through aliases. `remove`
deletes the inclusive interval; reversing the range does not change which
bytes are removed, and the cut must stay valid UTF-8. Search, split,
replacement, trimming, and case conversion remain methods. `toUpper()` and
`toLower()` perform ASCII case conversion; `trim()`/`strip()` trim ASCII
whitespace. See the `String` section of
[STDLIB.md](STDLIB.md) for the exact standard API. String operations use
UTF-8; byte offsets and character boundaries are not interchangeable.
Out-of-range indices and invalid conversions can raise exceptions. See
`STRING` and `postfix` for literal and call syntax.

```cwhip
// Complete program: basic string operations.
// test: {"stdout": "Hello world11"}
start {
    String text = "Hello"
    text.append(" world")
    print(text)
    print(text.length)
}
```

## `buffer` and `handle`

`buffer(length)` creates a mutable byte buffer of `length` zero-filled bytes.
`buffer[byte, ...]` creates a new buffer initialized from its elements;
`buffer[]` creates an empty buffer. Each element must have an integer type,
is evaluated once from left to right, and contributes its low 8
bits, matching indexed writes and `append`. Bare `[ ... ]` remains a
heterogeneous list literal. A buffer has a read-only `length`, supports
integer indexing and slicing, and provides `resize`, `clear`,
`append(integer)`, `insert(index, integer)`, and `remove(first..last)`.
`insert` accepts an index from `-length` through `length`. `remove` deletes
the inclusive interval and ignores range direction. Indexed values are
`uint8`; indexed assignment accepts every integer type. Source
lengths/indices are int64.
Bounds and allocation failures are
checked by the runtime.

`handle` is an opaque, nullable native/runtime handle. It has no language
operators, members, or automatic ownership policy; a library binding must
define how a handle is created and released. `buffer` and `handle` values can
be stored in collections and passed through `any`. See `primary`,
`index-or-slice-suffix`, and `postfix`.

```cwhip
// Complete program: byte-buffer literals, access, and mutation.
// test: {"stdout": "365"}
start {
    buffer bytes = buffer[65, 66]
    bytes.append(67)
    print(bytes.length)
    print(bytes[0])
}
```

```cwhip
// Fragment: native handles are opaque and must be released by their owner.
handle nativeResource = null
```

## Collections

List literals use `[...]` and may mix supported scalar values, strings,
type descriptors, integer ranges, class references, lists, dicts, buffers, handles, and
`null`. Values are
stored with dynamic tags, but `any` is not a type that can be declared for an
element, variable, field, parameter, or return.
`list.length` is read-only and int64. `append(value)`, `insert(index, value)`,
`remove(first..last)`, `resize(int64)`, and `clear()` mutate the list.
`append` and `insert` accept the same values a list literal accepts, including
buffers, handles, and type descriptors. `insert` accepts an index from
`-length` through `length`. `remove` deletes the inclusive interval; reversing
the range selects the same elements. Dicts provide `contains(string)`,
`remove(string)`, and `clear()`.
Indexing and foreach iteration produce values inferred as `any` internally,
not declared `any` variables. A dynamic value can be type-tested, passed,
printed, or compared with `null`; extract it into a concrete local before
using arithmetic. For class members, either extract into a typed local or
use a checked cast such as `(values[0] as Foo).method()`.
The runtime checks extraction.
List slices return a copy and can include a step:
`values[start:end:step]`. Bounds are checked by the runtime.

Dict literals use `[key: value, ...]`; `[:]` is an empty dict and `[]` is an
empty list. Keys must be strings; values may be
supported scalar/reference/collection types, including type descriptors.
Indexed reads and foreach
iteration produce dynamically tagged values inferred internally as `any`,
not legal `any` declarations. Dicts
support `length`, `contains(string)`, `remove(string)`, `clear()`, string-key indexing,
and slicing. Dict slice bounds are integer positions in iteration order;
stepped dict slices are not supported.

In the current runtime implementation, dict keys are hashed bytewise using
64-bit FNV-1a (offset basis `14695981039346656037`, prime `1099511628211`).
The hash index uses a power-of-two, open-addressed bucket table with linear
probing; the table grows and is rebuilt to keep its load at or below one
half. After a hash match, key byte length and byte contents are compared.
Entries themselves are stored in insertion order, so current iteration and
dict slicing follow insertion order. These are implementation details, not a
stable complexity guarantee. See `list-literal`, `dict-literal`,
`index-or-slice-suffix`, `foreach-statement`, and [STDLIB.md](STDLIB.md).

```cwhip
// Complete program: type-check and extract an indexed collection value.
// test: {"stdout": "42"}
start {
    list values = [42, "text"]
    if (values[0] is int8) {
        int8 number = values[0]
        print(number)
    }
}
```

## Threads and concurrency semantics

Thread support is provided through classes and native bindings, not a
threading keyword. The bundled runtime starts OS threads for thread objects
and dispatches their `run()` method. Cwhip-generated code executes under one
global runtime lock, so two Cwhip bodies do not execute managed code in
parallel. Blocking native operations such as `join()` and semaphore waits
release that lock, allowing another Cwhip thread to run. This provides
concurrency around waits, not parallel execution of Cwhip instructions.
The relevant source forms are `class-declaration`, `method-declaration`, and
`postfix`; none is a dedicated thread construct.

Use the standard synchronization package for its supported thread,
semaphore, mutex, and condition facilities; see [STDLIB.md](STDLIB.md).
Native handles and synchronization resources require the library's documented
lifetime operations. Guard shared state with the appropriate synchronization
primitive even though execution is serialized: native calls can block and
release the global lock.

```cwhip
// Fragment: requires a visible `Thread` base class supplied by declarations
// or a package. Thread operations are native bindings, not built-in syntax.
class Worker : Thread {
    public:
    void run() {
        print("worker")
    }
}
```

## Compiler and executable backend

The compiler lexes and parses Cwhip source, performs semantic analysis, emits
textual LLVM IR, and invokes Clang to compile and link the executable. Use
`--check-only` to run parsing and semantic checks without code generation, or
`--emit-llvm FILE` to also save the generated IR. The full command-line
interface is documented in [cwhip(1)](cwhip.1).
The compiler does not link the LLVM C++ API or provide a configurable LLVM
optimization pipeline; its Clang invocation is driven through the host POSIX
shell.

The implemented backend covers the language constructs in this reference:
scalar and String values, collections with tagged dynamic values, control
flow, exceptions, class construction and methods, inheritance (including
secondary and virtual bases), virtual dispatch, and native/inline-C bindings.
Printing accepts a single supported value or a double-quoted positional or
named format call. For how the source, parser, runtime, and tests are
organized, see [CWHIP-LANGUAGE-NOTES.md](CWHIP-LANGUAGE-NOTES.md) and the
[test guide](../tests/README.md).

Managed objects and collection values use a precise, non-moving,
stop-the-world mark/sweep collector. Generated functions publish explicit
root frames; arbitrary native stack words are not scanned. The runtime
serializes Cwhip execution under a global lock. OS threads can make progress
while another thread waits in a blocking native operation, but Cwhip
instructions do not execute in parallel. Exceptions use the host C ABI's
`setjmp`/`longjmp` mechanism rather than LLVM landing pads.

Known language/backend boundaries include no free-standing functions, no
automatic user-object `toString()` dispatch, no Unicode code-point operations, and no native-ABI lowering for
`any`. There is no general reflection API beyond `type(value)`. String
methods, Cwhip class methods, and C-bound methods described elsewhere remain
available; these limitations should not be confused with the obsolete claim
that formatted expressions or method overloading are unsupported.

## Garbage collection and destruction

Managed objects, strings, and collections are allocated on a runtime-managed
heap. The collector traces live roots (including locals and collection
references) and reclaims unreachable objects. A class `destroy { ... }`
definition is used as a finalizer when the collector reclaims an instance;
collection timing is not deterministic, so finalizers should not be used as a
substitute for explicit resource management. Finalizers must not let
exceptions escape.
Creating a `String` copies the source bytes into storage owned by that
string before the object is allocated. That storage is freed with the string.
`slice`, `trim`, and `split` therefore keep the bytes they observed at the
start of the call when a finalizer rewrites a live string during that
allocation. A catch-all `except() as name` copies the message
into a `String`. The exception frame keeps its own message bytes until that
frame is cleared.
The current runtime collects according to an adaptive allocation budget.
For root/finalizer stress testing, launch the program with `CWHIP_GC_STRESS=1`
to collect before every managed allocation. This diagnostic setting does not
change reachability or destruction rules; programs must not depend on collection
frequency.
Explicit `object.destroy()` runs the method but does not immediately reclaim
the object's storage. It marks the object destroyed before running the
destructor chain; a repeated call or later use raises a catchable runtime
exception, and GC will not run the destructor chain a second time.

Derived and base destruction is handled by the runtime destructor chain,
most-derived first and then through its bases. Unreachable objects are
finalized during garbage collection, whose timing is nondeterministic.
Resources requiring prompt release should be closed explicitly through their
library API. See `destructor-declaration` and `postfix`, and
[STDLIB.md](STDLIB.md).

```cwhip
// Fragment: finalizer timing is controlled by garbage collection.
class Resource {
    public:
    destroy {
        print("resource became unreachable")
    }
}
```

## Native bindings for library authors

Declare a method in a class and define it outside the class with a `from`
binding:

```cwhip
// Fragment: declaration and matching external C ABI binding.
class System {
    public:
    String lastError()
}

String System.lastError() from "cwhip_system_last_error"
```

The external symbol must be linkable by Clang and use the runtime's expected
ABI. Primitive parameters/results use the corresponding C/LLVM scalar
representation (exact-width C integers, C `float` for fp32, `double` for fp64,
and the existing bool boundary). Narrow integer parameters/results include the
target's required extension attributes. Strings, lists, dicts, buffers, handles, and class
references are pointer-based. `void` is allowed only as a method result.
Declarations and definitions must have matching names, parameter types, and
return types, and native definitions must be in the same compilation unit
and namespace as their class. See `method-declaration` and
`out-of-line-definition`.

`inline { ... }` embeds raw C in a method, constructor, destructor, or start
block. `inline (type name, ...)` captures existing locals/parameters first,
then accessible instance fields of the current receiver. There are no static
field captures, and `start` has no instance receiver. Capture types must match
exactly; inaccessible, unavailable, and ambiguous inherited fields are errors.
Use `type .field` to bypass a local that shadows a field, or `type Base.field`
and `type Base.OtherBase.field` to select an inheritance path. Qualification
uses the existing implicit-this/base access rules, not arbitrary object
expressions. The final field name becomes the C parameter name; two captures
with the same final name are rejected even if their paths differ.

Captures are mutable references to the actual storage slot, not copies.
For example, `*count += 1` in C updates the captured Cwhip `int64` when the
capture is int64 (the C pointer is then `int64_t *`). Managed
reference slots remain traced through rooted locals or the rooted receiver;
buffers use `CwhipBuffer **`, other managed references use `void **`.
Primary, secondary, repeated nonvirtual, and shared virtual bases use the same
receiver adjustment as Cwhip field assignments. The declare-and-capture
sugar below still declares a **local**, never a field.

```cwhip
// Fragment: the declared local is implicitly captured by this inline C block.
int64 result inline {
    *result = 42;
}
```

```cwhip
class Counter {
    // test: {"stdout": "101"}
    public:
    int64 count
    Counter() { count = 0 }
    void add(int64 count) {
        inline (int64 .count) { *count += 1; }
        // The parameter still shadows the field in ordinary unqualified access.
        print(count)
    }
}
start {
    Counter counter = Counter()
    counter.add(10)
    print(counter.count) // 1
}
```

### Application-facing inline API

Application developers do not need runtime implementation source. Prefer the
Cwhip standard-library class wrappers for ordinary code. Inline C automatically
receives the installed, supported opaque C facade `cwhip/Stdlib.h`; it exposes
the existing native implementations of the eight shipped standard packages
without inspecting private objects. See [the standard library C API](STDLIB.md#inline-c-api)
for the symbol mapping, errors, lifetime rules, and limitations. This is a real
C bridge to those functions, **not** a facility for calling arbitrary Cwhip
methods or wrapper constructors from C.

Generated shims also include `stdlib.h`, `stdio.h`, `string.h`, `errno.h`,
`ctype.h`, `stdint.h`, `limits.h`, and `unistd.h` once per translation unit,
before all C bodies. Their normal C APIs are available without user includes.
`unistd.h` is **POSIX-only**: the current compiler/runtime build requires a
POSIX host/target with that header, and CMake rejects its absence. If the Clang
target lacks any required header, shim compilation fails with a diagnostic;
headers are never silently omitted. The compiler uses its configured native
Clang target, not a separate inline-C cross-compilation target.

Inline C must preserve the language's value representation and GC invariants.
`malloc` memory is not managed Cwhip storage; do not put it into a String,
collection, buffer, or class reference slot. Raw native resources belong in
`handle` slots and require explicit cleanup. Do not retain capture addresses
or string-conversion pointers beyond the block, or leave the raw body with
`return`, `longjmp`, or another transfer that bypasses shim cleanup.
Legacy runtime declarations retained by the capture shim for compatibility
are not an application API promise; do not depend on private layouts or other
`Runtime*.h` interfaces.
