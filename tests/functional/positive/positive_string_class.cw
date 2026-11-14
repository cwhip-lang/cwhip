class Text {
    public:
    strg wrap(strg value) {
        return(format("[{}]", value))
    }
}

class ExtendedString : String {
    public:
    ExtendedString() {
        super String()
    }
}

class Order {
    public:
    int64 count
    int64 next() {
        count = count + 1
        return(count)
    }
}

start {
    strg original = "hi"
    String alias = original
    print(original == alias)
    alias.append("!")
    print(original)
    print(original.length)
    print(original.equals("hi!"))
    print(original == "hi!")
    print(original is String)
    print(original is strg)
    print(type(original) == String)
    print(type(original) == strg)
    ExtendedString derived = ExtendedString()
    print(derived is String)
    String base = derived
    print(base.length)
    derived.append("x")
    print(base)

    strg formatted = format("value {} {}", 42, true)
    print(formatted)
    Order order = Order()
    strg ordered = format("{} {}", order.next(), order.next())
    print(ordered)
    print(order.count)
    print(Text().wrap(original))
    list values = [format("list {}", original)]
    strg item = values[0]
    print(item)
    dict formattedKey = [format("key {}", 1): 7]
    print(formattedKey["key 1"])
    dict lookup = ["key": 1]
    strg key = "key"
    lookup[key] = 5
    key.append("!")
    print(lookup["key"])
    print(lookup.contains("key"))
    print("9".toInt64())
    print("11".toUint64())
    print("1.5".toFp64())
    strg empty = null
    print(empty == null)
    print(type(empty))
    print(original.find("h"))
}
