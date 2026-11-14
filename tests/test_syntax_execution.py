"""Execute the syntax migration contracts through the real compiler."""

import argparse
import os
from pathlib import Path
import subprocess
import tempfile


PROGRAM = r'''
class Answer {
    public:
    int32 value() { return(6 * 7) }
    void done() { return() }
    void bare() { return }
}
start {
    # Python bitwise precedence, with both comparison families.
    print(8 >> 1 & 3 ^ 2 | 1 == 3)
    print(1 | 2 < 4)
    print(!1 & 2 == 0)
    print(not false and true || false or true && false)
    list values = [
        1 +
        2,
        4,
    ]
    dict entries = [
        "a": values,
        "b": [
            7, /* line
                  continuation */ 8,
        ],
    ]
    dict empty = [:]
    list none = []
    list first = entries["a"]
    list second = entries["b"]
    print(first[0])
    print(second[1])
    print(empty.length)
    print(none.length)
    Answer answer()
    print(answer.value())
    answer.done()
    answer.bare()
    try {
        raise(Exception("syntax"))
    } except(Exception) as error {
        print(error.message)
    }
    print("# ; // /* stay in strings")
    int32 native = 0
    inline(int32 native) {
        *native = 5; /* C semicolons remain valid here. */
    }
    print(native)
}
'''

MIGRATION_ERRORS = (
    ("start { dict d = {} }\n", "dict literals now use [k: v]"),
    ('start { dict d = {"k": 1} }\n', "dict literals now use [k: v]"),
    ("class X { public: int32 f() { return 1 } }\nstart {}\n",
     "return value must be parenthesized: return(expr)"),
    ("class X { public: int32 f() { return(1) + 2 } }\nstart {}\n",
     "return value must be parenthesized: return(expr)"),
    ("start { raise 1 }\n", "raise arguments must be parenthesized: raise(expr)"),
    ("start { ; legacy comment\n}\n", "';' is not a comment; use '#' or '//'"),
    ("start { list d = [1, 2: 3] }\n", "cannot mix list elements and dict entries"),
    ("start { dict d = [1: 2, 3] }\n", "cannot mix list elements and dict entries"),
)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--compiler", required=True)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="cwhip-syntax-execution-") as directory:
        root = Path(directory)
        source = root / "syntax.cw"
        executable = root / "syntax"
        source.write_text(PROGRAM, encoding="utf-8")
        subprocess.run(
            [args.compiler, str(source), "-o", str(executable)],
            check=True,
        )
        result = subprocess.run(
            [str(executable)], check=True, capture_output=True, text=True,
            env=os.environ.copy(),
        )
        expected = (
            "truetruefalsetrue380042syntax"
            "# ; // /* stay in strings5"
        )
        if result.stdout != expected:
            raise AssertionError(f"expected {expected!r}, got {result.stdout!r}")
        for program, diagnostic in MIGRATION_ERRORS:
            source.write_text(program, encoding="utf-8")
            result = subprocess.run(
                [args.compiler, "--check-only", str(source)],
                capture_output=True, text=True,
            )
            if result.returncode == 0 or diagnostic not in result.stderr:
                raise AssertionError(
                    f"expected nonzero exit and {diagnostic!r}, got "
                    f"{result.returncode}: {result.stderr}"
                )


if __name__ == "__main__":
    main()
