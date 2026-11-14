class Base {
    public:
    int64 value
    Base(int64 initial) { value = initial }
    int64 read() { return(value)}
}
class Derived : Base {
    public:
    Derived(int64 initial) { super Base(initial) }
}
class Native {
    public:
    handle saved
}
start {
    handle token inline {
        *token = (void *)(uintptr_t)0x1234;
    }
    list payloads = [int64(42), uint64(9u), true, fp64(2.5), "text",
                     [int64(7)], ["key": int64(8)],
                     buffer(1), token, Derived(11), int64, null]
    dict descriptors = ["kind": int64]
    list descriptorList = []
    descriptorList.append(bool)
    int64 integer = payloads[0] as int64
    uint64 count = payloads[1] as uint64
    bool flag = payloads[2] as bool
    fp64 real = payloads[3] as fp64
    strg text = payloads[4] as strg
    list sequence = payloads[5] as list
    dict mapping = payloads[6] as dict
    buffer bytes = payloads[7] as buffer
    handle extractedToken = payloads[8] as handle
    Base base = payloads[9] as Base
    Derived derived = payloads[9] as Derived
    type descriptor = payloads[10] as type
    type mappedDescriptor = descriptors["kind"] as type
    type appendedDescriptor = descriptorList[0] as type
    print(integer)
    print(count)
    print(flag)
    print(real)
    print(text)
    print(sequence[0])
    print(mapping["key"])
    print(bytes.length)
    print((payloads[5] as list)[0])
    print((payloads[6] as dict)["key"])
    print((payloads[7] as buffer)[0])
    print((payloads[9] as Base).read())
    print(type(extractedToken))
    print(base.read())
    print(derived.read())
    print(descriptor)
    print(mappedDescriptor)
    print(appendedDescriptor)
    print(payloads[0] as any)
    print((int64(7) as any) as int64)
    print(null as any)
    print(type(payloads[11] as null))
    print((payloads[11] as any) == null)

    Base emptyBase = null
    strg emptyText = null
    list emptyList = null
    dict emptyDict = null
    buffer emptyBuffer = null
    handle emptyHandle = null
    print((emptyBase as Base) == null)
    print(type(emptyBase as null))
    print((emptyText as String) == null)
    print(type(emptyList as null))
    print(type(emptyDict as null))
    print((emptyBuffer as buffer) == null)
    print((emptyHandle as handle) == null)
    print(type(emptyBuffer as null))
    print(type(emptyHandle as null))

    try {
        int64 wrong = payloads[1] as int64
    } except(Exception) { print("int mismatch") }
    try {
        uint64 wrong = payloads[0] as uint64
    } except(Exception) { print("unsigned mismatch") }
    try {
        bool wrong = payloads[0] as bool
    } except(Exception) { print("bool mismatch") }
    try {
        fp64 wrong = payloads[0] as fp64
    } except(Exception) { print("float mismatch") }
    try {
        strg wrong = payloads[0] as strg
    } except(Exception) { print("string mismatch") }
    try {
        list wrong = payloads[0] as list
    } except(Exception) { print("list mismatch") }
    try {
        dict wrong = payloads[0] as dict
    } except(Exception) { print("dict mismatch") }
    try {
        buffer wrong = payloads[0] as buffer
    } except(Exception) { print("buffer mismatch") }
    try {
        handle wrong = payloads[0] as handle
    } except(Exception) { print("handle mismatch") }
    try {
        type wrong = payloads[0] as type
    } except(Exception) { print("type mismatch") }
    try {
        Derived wrong = payloads[0] as Derived
    } except(Exception) { print("class mismatch") }
    try {
        print(type(payloads[0] as null))
    } except(Exception) { print("null mismatch") }
    try {
        list nullList = [null]
        list wrong = nullList[0] as list
    } except(Exception) { print("list null extraction mismatch") }
    try {
        list wrong = payloads[11] as list
    } except(Exception) { print("null list extraction mismatch") }
    try {
        dict wrong = payloads[11] as dict
    } except(Exception) { print("null dict extraction mismatch") }
    try {
        int64 wrong = null as int64
    } except(Exception) { print("null scalar mismatch") }
    try {
        Base wrong = payloads[0] as Base
    } except(Exception) { print("object mismatch") }
}
