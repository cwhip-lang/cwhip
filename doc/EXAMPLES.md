# Build and run examples

After [building the compiler](INSTALLATION.md), the runnable product examples
in `examples/` use the canonical `.cw` suffix. The focused commands below also
compile checked-in functional fixtures, run the resulting executables, and
show the expected output or behavior:

Formatting uses literal templates, not calls on string literals:

```cwhip
// test: {"stdout": "this is 420000002AASCII: Aliteral {}"}
start {
    strg message = format("this is {}", 42)
    print(message)
    print("{value:08X}", value=42)
    print("ASCII: {:c}", 65)
    print("literal {}")
}
```

This writes `this is 42`, `0000002A`, `ASCII: A`, and `literal {}` with no
implicit line breaks.
`c` accepts only ASCII 0..127. See the language reference for the supported
specifier subset.

```sh
./bin/cwhip tests/functional/positive/positive_integer_output.cw \
  -o bin/positive_integer_output
./bin/positive_integer_output
# Prints: 42

./bin/cwhip tests/functional/positive/positive_integer_control_flow.cw \
  -o bin/positive_integer_control_flow
./bin/positive_integer_control_flow
# Prints: 9

./bin/cwhip tests/functional/positive/positive_string_format.cw \
  -o bin/positive_string_format
./bin/positive_string_format
# Writes "café\nvalue: 42sum 21 21"; print adds no implicit line breaks.

./bin/cwhip tests/functional/positive/positive_class_counter.cw \
  -o bin/positive_class_counter
./bin/positive_class_counter
# Prints: 424242

./bin/cwhip tests/functional/positive/positive_gc_object_graph.cw \
  -o bin/positive_gc_object_graph
./bin/positive_gc_object_graph
# Prints: 16477 after repeated collections.

./bin/cwhip tests/functional/positive/positive_multiple_inheritance.cw \
  -o bin/positive_multiple_inheritance
./bin/positive_multiple_inheritance
# Prints: 7710203; the two Root subobjects hold separate Node references.

./bin/cwhip tests/functional/positive/positive_secondary_bases.cw \
  -o bin/positive_secondary_bases
./bin/positive_secondary_bases
# Exercises secondary-base construction, conversions, dispatch, GC tracing, and destruction.
```

To save the generated LLVM IR as well as building an executable:

```sh
./bin/cwhip tests/functional/positive/positive_integer_output.cw \
  --emit-llvm build/positive_integer_output.ll -o bin/positive_integer_output
```

These are executable regression fixtures under `tests/functional/`, not
teaching examples. For hand-debuggable programs extracted from generative
drivers, see [`../tests/repro/`](../tests/repro/). The grammar and language
reference describe each feature; see [`../tests/README.md`](../tests/README.md)
for adding or running tests.

## Switches and integer ranges

The four standalone programs below are registered in `tests/examples.json`;
their complete output is checked by the existing example runner.
From the repository root, use your built compiler (`./bin/cwhip`) or an
installed `cwhip`:

```sh
cwhip examples/switch_delivery.cw -o /tmp/switch_delivery
/tmp/switch_delivery
cwhip examples/range_snapshots.cw -o /tmp/range_snapshots
/tmp/range_snapshots
cwhip examples/range_windows.cw -o /tmp/range_windows
/tmp/range_windows
cwhip examples/range_slices.cw -o /tmp/range_slices
/tmp/range_slices
```

### Delivery classification with switch

`examples/switch_delivery.cw` uses class enum constants in the grouped label
`case (Delivery.FIRST..Delivery.LAST, 7..5, 10) { ... }`. Parentheses and
braces are required. Ascending and descending intervals both match inclusively;
overlapping alternatives, even in the same group, are compile-time errors.
Labels must be compile-time integers, unlike the runtime endpoints allowed
when forming range values. `next` enters the next body without testing its
label: day 2 and day 6 both print the reminder even though its label is 99.

```text
scheduled day 2
send reminder
scheduled day 6
send reminder
unscheduled day 4
```

### Captured bounds, not live variables

`examples/range_snapshots.cw` prints each endpoint evaluation. The first
endpoint runs before the last, exactly once each. Changing `last` inside
the loop does not extend the saved interval. The iterator is read-only;
assigning to it (including through a mutable inline alias) is rejected.
The first loop's values and the last line have trailing spaces.

```text
capture 2
capture 4
2 3 4 
captures: 2, source last: 8
new range: 2..8
0..-1 visits: 0 -1 
```

Every formed interval is nonempty: guard `count > 0` before `0..count-1`,
or iterate a collection directly. Terminal-before-step iteration is safe at
integer extrema; that does not promise a representable full-domain count or
protect an accumulator in the loop body from ordinary integer overflow.

### Reusable windows and membership

`examples/range_windows.cw` passes and returns a `range<int64>`, stores it in a
list, and extracts the exact type. Membership ignores the traversal direction.
The mixed endpoint example uses lossless promotion to `range<int16>`.

```text
saved: 5..3, total: 12
4 included: true, 6 included: false
restored: 5..3
mixed: -1..2, negative included: true
```

Small literal endpoints infer small integer types. Typed ranges can widen
losslessly; signed endpoints mixed with `uint64` need an explicit conversion.
Dynamic collection extraction requires the actual endpoint type before
widening. Float/bool/object endpoints need a valid explicit integer conversion.
These examples add no stride, equality, count, or endpoint-accessor API;
printing a range displays its captured bounds. Consuming a null range for
iteration, membership, or slicing raises a catchable exception.

### Copies, inclusive indices, and UTF-8

`examples/range_slices.cw` shows inclusive forward and reverse slices.
Negative indices retain their normal meaning (`-1` is the last element).
Changing the source does not mutate the copy's outer storage, but nested
lists and objects are still shared. Buffers copy bytes.

```text
forward: 20 30, reverse: 40 30
shared nested value: 7
buffer copy: 30 20 10
buffer forward: 10 20
ASCII reverse: dcb, UTF-8 bytes: é
partial UTF-8 rejected
out-of-bounds rejected
empty slice rejected
```

String indices are UTF-8 **byte** offsets. `"aéz"[1..2]` selects the complete
two-byte character; `[1..1]` is invalid, and reversing multibyte character
bytes can also fail UTF-8 validation. Both slice endpoints must exist:
there is no clamping and no valid range slice of an empty collection.
These are copies, not assignment targets or views. Existing colon slices
and String `.slice` retain their separate half-open/clamped rules.
See [constant switches](LANGUAGE-REFERENCE.md#constant-switches) and
[integer ranges](LANGUAGE-REFERENCE.md#integer-ranges) for the full contracts.

## Package workflow

After installing `cwhip` and `cwhip-pkg` on `PATH`, a project with nested sources
needs no environment activation:

```sh
mkdir -p hello-cwhip/src
cd hello-cwhip
cwhip-pkg init
# Copy examples/package_workflow.cw from this repository to src/main.cw.
cwhip src/main.cw -o hello
./hello
```

The example uses the default exported `System` namespace, a `math` alias,
and the implicit `String` prelude. `init` locks the bundled packages locally,
without network access. For an external dependency, review its repository and
run `cwhip-pkg add OWNER/REPO VERSION --yes`; the command installs the complete
declared graph and updates the manifest/lock. `cwhip-pkg install --yes` restores
that lock on another checkout. See [package schemas and plan/consent
behavior](PACKAGES.md) before adding untrusted dependencies.
