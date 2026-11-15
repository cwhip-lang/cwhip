/*
 * tests/functional/positive/positive_default_package_namespace.cw
 *
 * Checks default package namespace.
 *
 * Created: 2026-10-05
 * Author: chuck
 *
 * Changelog:
 *   2026-10-05  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import system
import system as Sys
import math

start {
    String text = "hello"
    print(text)
    print(Math.Math().sqrt(9.0) == 3.0)
    print(System.FileSystem().isDir("."))
    print(Sys.FileSystem().isDir("."))
}
