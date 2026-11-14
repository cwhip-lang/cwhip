# A finalizer rewrites a live string during a range copy, trim, and split.
# Each result must be the bytes observed at the start of that call.
class Box {
    public:
    strg text
    Box(strg value) {
        text = value
    }
}

class Mutator {
    public:
    Box box
    Mutator(Box target) {
        box = target
    }
    destroy {
        strg text = box.text
        text.clear()
        inline (strg text) {
            const char bytes[] = {'Z', 'Z', 'Z', 'Z', 'Z', 'Z'};
            cwhip_string_append_bytes(*text, bytes, 6);
        }
    }
}

class Maker {
    public:
    void abandon(Box box) {
        Mutator gone = Mutator(box)
    }
}

start {
    Maker maker = Maker()
    Box sliceBox = Box("abcdef")
    range<int64> bounds = 1..3
    maker.abandon(sliceBox)
    strg sliced = sliceBox.text[bounds]
    print(sliced)
    print("\n")
    print(sliceBox.text)
    print("\n")

    Box trimBox = Box("  ab  ")
    maker.abandon(trimBox)
    strg trimmed = trimBox.text.trim()
    print(trimmed)
    print("\n")
    print(trimBox.text)
    print("\n")

    Box splitBox = Box("a,b,c")
    strg comma = ","
    maker.abandon(splitBox)
    list parts = splitBox.text.split(comma)
    strg first = parts[0]
    strg second = parts[1]
    strg third = parts[2]
    print(first)
    print("\n")
    print(second)
    print("\n")
    print(third)
    print("\n")
    print(splitBox.text)
    print("\n")
}
