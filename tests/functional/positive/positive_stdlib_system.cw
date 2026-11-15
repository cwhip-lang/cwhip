/*
 * tests/functional/positive/positive_stdlib_system.cw — Checks stdlib system.
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
    print(process.argc() > 0)
    print(process.argv().length == process.argc())
    print(process.arg(0).length > 0)
    print(process.setEnv("CWHIP_STDLIB_TEST", "value"))
    print(process.getEnv("CWHIP_STDLIB_TEST").equals("value"))

    bool fileRaised = false
    try {
        Sys.File file = Sys.File("sample.txt", "r")
    }
    except(Exception) {
        fileRaised = true
    }
    print(fileRaised)

    Sys.FileSystem fileSystem = Sys.FileSystem()
    print(fileSystem.exists("."))
    print(fileSystem.isFile(".") == false)
    print(fileSystem.isDir("."))
    print(fileSystem.fileSize(".") == -1)
    print(fileSystem.remove("sample.txt") == false)
    print(fileSystem.rename("old.txt", "new.txt") == false)
    print(fileSystem.copy("source.txt", "destination.txt") == false)
    print(fileSystem.mkdir("stdlib-system-smoke"))
    print(fileSystem.rmdir("stdlib-system-smoke"))
    print(fileSystem.listDir(".").length > 0)
    print(fileSystem.getCwd().length > 0)
    print(fileSystem.chDir("."))
    print(fileSystem.absolutePath(".").length > 0)

    Sys.System system = Sys.System()
    print(system.argc() == process.argc())
    print(system.argv().length == process.argc())
    print(system.arg(0).equals(process.arg(0)))
    bool openedRaised = false
    try {
        Sys.File opened = system.open("sample.txt", "r")
    }
    except(Exception) {
        openedRaised = true
    }
    print(openedRaised)
    print(system.exists("."))
    print(system.getEnv("CWHIP_STDLIB_TEST").equals("value"))
}
