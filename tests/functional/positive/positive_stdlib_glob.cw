/*
 * tests/functional/positive/positive_stdlib_glob.cw — Checks stdlib glob.
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
    Sys.FileSystem fileSystem = Sys.FileSystem()
    Sys.Glob globber = Sys.Glob()
    String directory = "glob-test"
    print(fileSystem.mkdir(directory))
    print(fileSystem.mkdir("glob-test/sub"))

    Sys.File file = Sys.File("glob-test/zeta.txt", "w")
    file.close()
    file = Sys.File("glob-test/ab.txt", "w")
    file.close()
    file = Sys.File("glob-test/a1.txt", "w")
    file.close()
    file = Sys.File("glob-test/beta.txt", "w")
    file.close()
    file = Sys.File("glob-test/readme.dat", "w")
    file.close()
    file = Sys.File("glob-test/sub/inner.txt", "w")
    file.close()

    list textFiles = globber.glob("glob-test/*.txt")
    print(textFiles.length == 4)
    String matchedPath = textFiles[0]
    print(matchedPath.equals("glob-test/a1.txt"))
    matchedPath = textFiles[1]
    print(matchedPath.equals("glob-test/ab.txt"))
    matchedPath = textFiles[2]
    print(matchedPath.equals("glob-test/beta.txt"))
    matchedPath = textFiles[3]
    print(matchedPath.equals("glob-test/zeta.txt"))

    list questionMatches = globber.glob("glob-test/a?.txt")
    print(questionMatches.length == 2)
    matchedPath = questionMatches[0]
    print(matchedPath.equals("glob-test/a1.txt"))
    matchedPath = questionMatches[1]
    print(matchedPath.equals("glob-test/ab.txt"))

    list bracketMatches = globber.glob("glob-test/[bz]*.txt")
    print(bracketMatches.length == 2)
    matchedPath = bracketMatches[0]
    print(matchedPath.equals("glob-test/beta.txt"))
    matchedPath = bracketMatches[1]
    print(matchedPath.equals("glob-test/zeta.txt"))

    list nestedMatches = globber.glob("glob-test/sub/*.txt")
    print(nestedMatches.length == 1)
    matchedPath = nestedMatches[0]
    print(matchedPath.equals("glob-test/sub/inner.txt"))

    print(fileSystem.exists("missing-glob-error-test") == false)
    list noMatches = globber.glob("glob-test/no-match-*.txt")
    print(noMatches.length == 0)
    print(Sys.System().lastError().length == 0)

    print(fileSystem.remove("glob-test/zeta.txt"))
    print(fileSystem.remove("glob-test/ab.txt"))
    print(fileSystem.remove("glob-test/a1.txt"))
    print(fileSystem.remove("glob-test/beta.txt"))
    print(fileSystem.remove("glob-test/readme.dat"))
    print(fileSystem.remove("glob-test/sub/inner.txt"))
    print(fileSystem.rmdir("glob-test/sub"))
    print(fileSystem.rmdir(directory))
}
