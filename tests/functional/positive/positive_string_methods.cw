/*
 * tests/functional/positive/positive_string_methods.cw
 *
 * Exercises String byte/range methods, search, splitting, replacement,
 * trimming, ASCII case conversion, UTF-8 boundary checks, and embedded NULs.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    strg text = "a,b,,c,"
    print(text[0])
    print(text[-1])
    print(text[2..4])
    print(text[-4..-2])
    print(text.find("b"))
    print(text.find(""))
    print(text.find("missing"))
    print(text.contains(",,"))
    print(text.contains("missing"))
    print(text.startsWith("a,"))
    print(text.startsWith(""))
    print(text.endsWith(","))
    print(text.endsWith(""))

    list parts = text.split(",")
    print(parts.length)
    strg part = parts[0]
    print(part)
    part = parts[1]
    print(part)
    part = parts[2]
    print(part)
    part = parts[3]
    print(part)
    part = parts[4]
    print(part)
    part = "".split(",")[0]
    print(part)

    print("aaaa".replace("aa", "b"))
    print("abc".replace("z", ""))
    print(" \t hello \r\n".trim())
    print("  spaced  ".strip().equals("spaced"))
    print("\nnewline\n".strip().equals("newline"))
    print("\r\nwrapped\r\n".strip().equals("wrapped"))
    print("\t\ttabbed\t".strip().equals("tabbed"))
    print("inside \n stays".strip().equals("inside \n stays"))
    print(" \t\n\r".strip().length)
    print("".strip().length)
    strg stripSource = " \nkeep\r\n"
    strg stripped = stripSource.strip()
    print(stripSource.equals(" \nkeep\r\n"))
    print(stripped.equals("keep"))
    print(stripped == stripSource)
    strg unchanged = "plain"
    strg unchangedStrip = unchanged.strip()
    print(unchangedStrip == unchanged)
    print("ab-é".toUpper())
    print("AB-é".toLower())

    strg unicode = "Aé中Z"
    print(unicode.length)
    print(unicode[-1])
    print(unicode[2])
    print(unicode.find("中"))
    print(unicode[1..2])
    print(unicode[-4..-2])
    print(unicode[0..6])
    print("".length)
    print(unicode.toUpper())
    strg equalCopy = unicode[0..unicode.length - 1]
    print(equalCopy == unicode)
    print(equalCopy.equals(unicode))

    strg mutable = "abcd"
    strg alias = mutable
    mutable.insert(-1, "XY")
    print(alias)
    mutable.insert(0, mutable)
    print(mutable)
    mutable.remove(0..3)
    print(alias)
    mutable.clear()
    print(mutable.length)
    strg selfInsert = "xy"
    selfInsert.insert(1, selfInsert)
    print(selfInsert)
    strg clamped = "abc"[0..2]
    print(clamped)

    strg nul = "a"
    inline (strg nul) {
        const char bytes[] = { 0, 'b' };
        cwhip_string_append_bytes(*nul, bytes, 2);
    }
    print(nul.length)
    print(nul[1])
    print(nul[2])
    strg nulNeedle = ""
    inline (strg nulNeedle) {
        const char byte[] = { 0 };
        cwhip_string_append_bytes(*nulNeedle, byte, 1);
    }
    print(nul.find(nulNeedle))
    print(nul.contains(nulNeedle))
    strg nulReplacement = nul.replace(nulNeedle, "X")
    print(nulReplacement.length)
    print(nulReplacement[1])
    print(nulReplacement[2])

    try {
        uint8 ignored = unicode[20]
    }
    except() {
        print("byte bounds")
    }
    try {
        strg broken = unicode[2..3]
    }
    except() {
        print("slice boundary")
    }
    try {
        unicode.insert(2, "x")
    }
    except() {
        print("insert boundary")
    }
    try {
        unicode.remove(2..3)
    }
    except() {
        print("remove boundary")
    }
    try {
        text.insert(20, "x")
    }
    except() {
        print("insert bounds")
    }
    try {
        text.split("")
    }
    except() {
        print("empty separator")
    }
    try {
        text.replace("", "x")
    }
    except() {
        print("empty target")
    }
    try {
        text.find(null)
    }
    except() {
        print("null needle")
    }
    try {
        text.startsWith(null)
    }
    except() {
        print("null prefix")
    }
    try {
        text.endsWith(null)
    }
    except() {
        print("null suffix")
    }
    try {
        text.split(null)
    }
    except() {
        print("null separator")
    }
    try {
        text.replace("a", null)
    }
    except() {
        print("null replacement")
    }
    try {
        strg missing = null
        missing.clear()
    }
    except() {
        print("null receiver")
    }
}
