/*
 * tests/functional/positive/positive_stdlib_system_os.cw
 *
 * Checks stdlib system os.
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
    Sys.StandardIO io = Sys.StandardIO()
    print(io.readLine().equals("first line"))
    print(io.read(6).equals("second"))
    print(io.write("stdout") == 6)
    io.flush()
    buffer outBytes = buffer(1)
    outBytes[0] = 33
    print(io.writeBytes(outBytes) == 1)
    buffer errorBytes = buffer(2)
    errorBytes[0] = 63
    errorBytes[1] = 10
    print(io.writeErrorBytes(errorBytes) == 2)
    print(io.writeErrorLine("stderr") == 7)
    io.flushError()
}
