/*
 * tests/functional/positive/positive_stdlib_process.cw
 *
 * Checks stdlib process.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import process as Child
import system as Sys

start {
    Child.Process command = Child.Process("/usr/bin/printf", ["hello %s", "$(echo shell)"])
    print(command.started())
    print(command.wait())
    print(command.exitCode() == 0)
    print(command.stdout().equals("hello $(echo shell)"))
    print(command.stderr().length == 0)
    command.close()

    Child.Process failure = Child.Process("/definitely/not/a/cwhip-command", [])
    print(failure.started() == false)
    print(Sys.System().lastError().length > 0)

    Child.Process nonzero = Child.Process("/usr/bin/ls", ["cwhip-file-that-does-not-exist"])
    print(nonzero.started())
    print(nonzero.wait())
    print(nonzero.exitCode() != 0)
    print(nonzero.stderr().length > 0)
    nonzero.close()

    Child.Process knownExit = Child.Process("/usr/bin/false", [])
    print(knownExit.started())
    print(knownExit.wait())
    print(knownExit.exitCode() == 1)
    knownExit.close()
}
