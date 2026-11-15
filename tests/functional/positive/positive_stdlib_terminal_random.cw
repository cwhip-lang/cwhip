/*
 * tests/functional/positive/positive_stdlib_terminal_random.cw
 *
 * Checks stdlib terminal random.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import random as Random
import terminal as Terminal
import system as Sys

start {
    Terminal.Terminal terminal = Terminal.Terminal()
    print(terminal.isInteractive() == false)
    print(terminal.isOutputInteractive() == false)
    print(terminal.columns() == 0)
    print(terminal.rows() == 0)
    print(terminal.supportsColor() == false)

    Random.SecureRandom secure = Random.SecureRandom()
    buffer generated = secure.bytes(32)
    print(generated != null)
    print(generated.length == 32)
    buffer destination = buffer(16)
    print(secure.fill(destination))
    print(destination.length == 16)
    print(secure.bytes(-1) == null)
    print(Sys.System().lastError().length > 0)
}
