# CWHIP Coding standard

This document is intended to be used by programmers writing code in the Cwhip programming language. This is a subset of the guidelines that is used by the AI that generated much of the proof of concept code that is located in this repository and others. 

## General guidelines

- Prefer to define class methods outside of the class body. This keeps the definition of the class small and readable.
- Always use a new line after a **{** and before a **}**. Including one line code blocks. This helps to visually define code blocks.
- Indents are 4 spaces. Continuations are allowed inside **[]** and **()** and indent is 8 spaces past the normal indent.
- Line length should be kept to less than 80 characters to allow clean editing on a console.

## Naming

- **Classes:** CamelCase, first letter capital.
- **Methods:** lowercase `with_under_score`.
- **Variables:** camelCase, first letter lower.
- **Enums:** `ALL_CAPS` with underscores — symbolic names for `int64`
  literals. Prefer enum/names over magic number literals.
- **Dict keys** are strings. The runtime implements **dict** as a simple hash table.

## Visibility / ownership

- Default visibility was intended private, but hiding data is seldom
  required — do **not** treat encapsulation as mandatory secrecy.
- Data allocated by an object (for example file handles) is **owned**
  by that object.
- Do not mix related attributes across objects without a good reason.
- Keep public class elements together, and document the interface to the class.

## Init / empty

- Do **not** require initializing all class variables in the
  constructor.
- No forward-declaration requirement, since Cwhip is a multi-pass compiler.
- An empty string is still a valid string (no extra validity rules).

## Exceptions / errors

- Use exceptions for **error recovery**, not for ordinary flow control.
- **Fatal:** rethrow so the stack trace surfaces.
- **Recoverable:** a console print is OK (it may go unseen).
- Prefer exceptions over return codes.
- There is **no** assertion feature that compiles out for production.

## Tests

- No tests embedded in production code unless unavoidable.
- All testing code and data live under `tests/` (no outside data unless
  unavoidable).
- All testing goes through **CTest**.
- Keep tests as small as practical; treat them as example code when
  practical.
- [PLAN.md](PLAN.md) still owns broader test-suite shape and work
  order; this section locks placement and delivery rules.

## FFI

- **Inline C** is the preferred way to interface external libraries unless you
  are implementing actual runtime code for Cwhip.
