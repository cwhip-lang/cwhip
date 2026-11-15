/*
 * tests/functional/positive/positive_stdlib_file_io.cw
 *
 * Checks stdlib file io.
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
    Sys.File output = Sys.File("file-io-test.txt", "w+")
    print(output.isOpen())
    print(output.writeLine("alpha"))
    print(output.writeLine("beta"))
    output.flush()
    print(output.tell())
    output.seek(0, 0)
    print(output.readLine())
    list remainingLines = output.readLines()
    print(remainingLines.length)
    String remaining = remainingLines[0]
    print(remaining)
    output.seek(0, 0)
    print(output.readAll())
    output.seek(0, 0)
    print(output.read(5))
    output.close()
    print(output.isOpen())

    Sys.File binary = Sys.File("file-io-test.bin", "wb")
    buffer bytes = buffer(256)
    int64 index = 0
    while (index < bytes.length) {
        bytes[index] = index
        index = index + 1
    }
    print(binary.writeBytes(bytes) == 256)
    print(binary.writeBytes(buffer(0)) == 0)
    binary.flush()
    binary.close()

    binary = Sys.File("file-io-test.bin", "rb")
    buffer allBytes = binary.readAllBytes()
    bool allBytesMatch = allBytes.length == 256
    index = 0
    while (index < allBytes.length) {
        if (allBytes[index] != bytes[index]) {
            allBytesMatch = false
        }
        index = index + 1
    }
    print(allBytesMatch)

    binary.seek(0, 0)
    buffer firstChunk = binary.readBytes(127)
    buffer secondChunk = binary.readBytes(129)
    bool chunksMatch = firstChunk.length == 127 && secondChunk.length == 129
    index = 0
    while (index < firstChunk.length) {
        if (firstChunk[index] != bytes[index]) {
            chunksMatch = false
        }
        index = index + 1
    }
    while (index < 256 && index - 127 < secondChunk.length) {
        if (secondChunk[index - 127] != bytes[index]) {
            chunksMatch = false
        }
        index = index + 1
    }
    print(chunksMatch)

    binary.seek(0, 0)
    buffer shortRead = binary.readBytes(300)
    print(shortRead.length == 256)
    print(Sys.System().lastError().length == 0)
    print(binary.eof())
    print(binary.readBytes(4).length == 0)
    print(Sys.System().lastError().length == 0)
    print(binary.readBytes(-1).length == 0)
    print(Sys.System().lastError().length > 0)
    binary.close()
    print(binary.readBytes(1).length == 0)
    print(Sys.System().lastError().length > 0)
    print(binary.writeBytes(bytes) == 0)
    print(Sys.System().lastError().length > 0)

    Sys.File emptyOutput = Sys.File("file-io-empty.bin", "wb")
    print(emptyOutput.writeBytes(buffer(0)) == 0)
    emptyOutput.close()
    Sys.File emptyInput = Sys.File("file-io-empty.bin", "rb")
    print(emptyInput.readAllBytes().length == 0)
    print(emptyInput.readBytes(1).length == 0)
    emptyInput.close()

    buffer largeBytes = buffer(32769)
    index = 0
    while (index < largeBytes.length) {
        largeBytes[index] = index % 256
        index = index + 1
    }
    Sys.File largeOutput = Sys.File("file-io-large.bin", "wb")
    print(largeOutput.writeBytes(largeBytes) == largeBytes.length)
    largeOutput.close()
    Sys.File largeInput = Sys.File("file-io-large.bin", "rb")
    buffer largeCopy = largeInput.readAllBytes()
    bool largeMatches = largeCopy.length == largeBytes.length
    index = 0
    while (index < largeCopy.length) {
        if (largeCopy[index] != largeBytes[index]) {
            largeMatches = false
        }
        index = index + 1
    }
    print(largeMatches)
    largeInput.close()
}
