/*
 * tests/functional/positive/positive_system_file_open_failure.cw
 *
 * Checks system file open failure.
 *
 * Created: 2026-10-12
 * Author: chuck
 *
 * Changelog:
 *   2026-10-12  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import system as System

start {
    bool caughtConstructor = false
    try {
        System.File file = System.File("nonexistent.txt", "r")
    }
    except(Exception) as err {
        caughtConstructor = err.message.contains("Cannot open file 'nonexistent.txt':")
    }
    print(caughtConstructor)

    bool caughtOpen = false
    try {
        System.File file = System.System().open("nonexistent.txt", "r")
    }
    except(Exception) as err {
        caughtOpen = err.message.contains("Cannot open file 'nonexistent.txt':")
    }
    print(caughtOpen)
}
