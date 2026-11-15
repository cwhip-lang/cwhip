/*
 * tests/functional/positive/positive_stdlib_argv.cw — Checks stdlib argv.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import system as Sys

start {
    Sys.Process process = Sys.Process()
    list arguments = process.argv()
    print(process.argc())
    print(arguments.length)
    print(process.arg(1).equals(arguments[1]))
    print(process.arg(2).equals(arguments[2]))
    String first = arguments[1]
    String second = arguments[2]
    print(first)
    print(second)
}
