# Exercises byte buffers, opaque native handles, dynamic values, collections, and inline capture.
class Native {
    public:
    int64 marker
    handle saved

    Native(int64 initial) {
        marker = initial
    }

    void save(handle value) {
        saved = value
    }

    handle recall() {
        return(saved)
    }

    handle create()
    void consume(handle value)
    handle identity(handle value)
    buffer identityBuffer(buffer value)
}

handle Native.create() from "cwhip_method_demo_handle_create"
void Native.consume(handle value) from "cwhip_method_demo_handle_consume"
handle Native.identity(handle value) from "cwhip_method_demo_handle_identity"
buffer Native.identityBuffer(buffer value) from "cwhip_method_demo_identity"

start {
    buffer bytes = buffer(2)
    print(bytes.length)
    bytes[0] = 300
    bytes[1] = -1
    print(bytes[0])
    bytes[0] = 300u
    print(bytes[0])
    print(bytes[1])

    bytes.resize(4)
    print(bytes.length)
    print(bytes[2])
    bytes.resize(1)
    bytes.resize(3)
    print(bytes[1])
    bytes.append(258u)
    print(bytes.length)
    print(bytes[3])
    bytes.append(-2)
    print(bytes.length)
    print(bytes[4])

    buffer piece = bytes[0:2]
    piece[0] = 9
    print(bytes[0])
    print(piece[0])

    buffer duplicate = bytes
    duplicate[0] = 7
    print(bytes[0])
    print(duplicate[0])
    bytes.clear()
    print(bytes.length)
    try {
        uint64 missing = bytes[0]
    } except() as message {
        print(message)
    }

    list buffers = [piece]
    buffer arrayBuffer = buffers[0]
    print(arrayBuffer[0])
    buffer extractedBuffer = buffers[0]
    print(extractedBuffer[1])
    dict bufferMap = ["bytes": piece]
    buffer mapBuffer = bufferMap["bytes"]
    print(mapBuffer[1])
    buffer nativeBuffer = Native(91).identityBuffer(piece)
    print(nativeBuffer[1])

    list aliases = [1]
    list arrayAlias = aliases
    aliases[0] = 2
    print(arrayAlias[0])
    dict mapAliases = ["value": 3]
    dict mapAlias = mapAliases
    mapAliases["value"] = 4
    print(mapAlias["value"])

    buffer missingBuffer = null
    print(missingBuffer == null)

    Native native = Native(91)
    handle nativeHandle = native.create()
    handle inlineHandle inline {
        *inlineHandle = (void *)(uintptr_t)0x1234;
    }
    print(nativeHandle != null)
    print(inlineHandle != null)
    native.consume(native.identity(inlineHandle))
    native.save(nativeHandle)
    handle fieldHandle = native.recall()
    print(fieldHandle != null)

    list inlineHandles = [inlineHandle]
    handle extractedHandle = inlineHandles[0]
    print(extractedHandle != null)
    list handles = [nativeHandle]
    handle arrayHandle = handles[0]
    native.consume(arrayHandle)
    dict handleMap = ["handle": inlineHandle]
    handle mapHandle = handleMap["handle"]
    native.consume(mapHandle)
    handle missingHandle = null
    print(missingHandle == null)
}
