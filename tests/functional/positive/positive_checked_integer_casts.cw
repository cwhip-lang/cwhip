/*
 * tests/functional/positive/positive_checked_integer_casts.cw
 *
 * Checks checked integer casts.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    fp64 signedMinimum = fp64(-9223372036854775808)
    fp64 signedLastRepresentable = fp64(9223372036854774784)
    fp64 unsignedLastRepresentable = fp64(18446744073709549568u)
    print(int64(signedMinimum))
    print(int64(signedLastRepresentable))
    print(uint64(unsignedLastRepresentable))
    print(int64(-3.99f64))
    print(uint64(3.99f64))

    try {
        print(int64(fp64(9223372036854775807)))
    }
    except() as error {
        print(error)
    }

    try {
        print(int64(-9223372036854777856.0f64))
    }
    except() as error {
        print(error)
    }

    try {
        print(int64(0.0 / 0.0))
    }
    except() as error {
        print(error)
    }

    try {
        print(uint64(-1.0f64))
    }
    except() as error {
        print(error)
    }

    try {
        print(uint64(fp64(18446744073709551615u)))
    }
    except() as error {
        print(error)
    }

    int64 minimum = -9223372036854775808
    try {
        print(minimum / -1)
    }
    except() as error {
        print(error)
    }

    try {
        print(minimum % -1)
    }
    except() as error {
        print(error)
    }
}
