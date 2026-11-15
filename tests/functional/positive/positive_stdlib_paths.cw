/*
 * tests/functional/positive/positive_stdlib_paths.cw — Checks stdlib paths.
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
    Sys.FileSystem paths = Sys.FileSystem()
    print(paths.join("/a/b", "../c").equals("/a/c"))
    print(paths.normalize("a/./b/../c").equals("a/c"))
    print(paths.normalize("../../a/../b").equals("../../b"))
    print(paths.basename("/a/c.txt").equals("c.txt"))
    print(paths.dirname("/a/c.txt").equals("/a"))
    print(paths.extension("/a/c.txt").equals("txt"))
    print(paths.extension(".hidden").length == 0)

    String temporaryFile = paths.tempFile()
    print(temporaryFile.length > 0)
    print(paths.exists(temporaryFile))
    Sys.File temporary = Sys.File(temporaryFile, "w")
    print(temporary.isOpen())
    print(temporary.write("original") == 8)
    temporary.close()
    print(paths.copy(temporaryFile, temporaryFile) == false)
    print(Sys.System().lastError().length > 0)
    print(paths.fileSize(temporaryFile) == 8)
    print(paths.remove(temporaryFile))

    String temporaryDirectory = paths.tempDir()
    print(temporaryDirectory.length > 0)
    print(paths.isDir(temporaryDirectory))
    print(paths.rmdir(temporaryDirectory))

    print(paths.exists("missing-file-for-error-test") == false)
    print(Sys.System().lastError().length > 0)
    print(paths.getCwd().length > 0)
}
