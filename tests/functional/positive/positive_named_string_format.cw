# Checks named formatting, escaped braces, supported values, and single evaluation.
class Counter {
    public:
    int64 calls
    Counter() {
        calls = 0
    }
    int64 next() {
        calls += 1
        return(calls)
    }
}

class Mutator {
    public:
    strg text
    Mutator(strg initial) {
        text = initial
    }
    strg change() {
        text.append("!")
        return(text)
    }
}

start {
    Counter counter = Counter()
    strg repeated = format("{value}/{value}", value=counter.next())
    print(repeated)
    print(counter.calls)

    print("{text}: {item_2}", item_2=42, text="result")
    print("{flag} {decimal} {whole} {text}",
        flag=true, decimal=1.25, whole=42u, text="café")
    print("escaped {{braces}} and {name}", name="ok")
    print("runtime type: {kind}", kind=type(42))

    list values = [true, 1.5, "dynamic"]
    print("dynamic value: {value}", value=values[1])
    print("positional {} {}", 7, false)

    Mutator mutator = Mutator("before")
    print("positional snapshot {} {}", mutator.text, mutator.change())
}
