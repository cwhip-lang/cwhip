/*
 * tests/functional/positive/positive_string_conversion.cw
 *
 * Exercises string-to-number conversion (s.toInt64(), s.toUint64(),
 * s.toFp64()): the built-in, non-class dot-operations on 'string', in the same
 * style as list.length/buffer.resize(). Covers success, a leading '+',
 * overflow, invalid characters (including trailing garbage and an empty
 * string), a negative sign rejected by toUnsigned, and a null receiver raising
 * instead of crashing.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    strg a = "42"
    strg b = "-17"
    strg c = "3.14"
    strg d = "255"

    print(a.toInt64())
    print(b.toInt64())
    print(d.toUint64())
    print(c.toFp64())

    strg plus = "+5"
    print(plus.toInt64())

    strg sci = "1.5e2"
    print(sci.toFp64())

    strg maxUnsigned = "18446744073709551615"
    print(maxUnsigned.toUint64())

    try {
        strg bad = "abc"
        print(bad.toInt64())
    }
    except() as e {
        print(e)
    }

    try {
        strg trailing = "12x"
        print(trailing.toInt64())
    }
    except() as e {
        print(e)
    }

    try {
        strg empty = ""
        print(empty.toInt64())
    }
    except() as e {
        print(e)
    }

    try {
        strg overflow = "9223372036854775808"
        print(overflow.toInt64())
    }
    except() as e {
        print(e)
    }

    try {
        strg negative = "-5"
        print(negative.toUint64())
    }
    except() as e {
        print(e)
    }

    try {
        strg n = null
        print(n.toInt64())
    }
    except() as e {
        print("null reference")
    }
}
