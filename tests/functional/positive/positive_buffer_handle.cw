/*
 * tests/functional/positive/positive_buffer_handle.cw
 *
 * Exercises byte buffers, opaque native handles, dynamic values, collections,
 * and inline capture.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Native is a class, used as a fixture by this test.
 *
 * Its methods include constructor, save, recall, create, consume, identity,
 * and 1 more.
 */
class Native {
    public:
    int64 marker
    handle saved

    /*
     * Constructs a Native and stores marker.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Native.
     */
    Native(int64 initial) {
        marker = initial
    }

    /*
     * Stores value in saved.
     *
     * Parameters:
     *   value — handle value.
     *
     * Does not return a value.
     */
    void save(handle value) {
        saved = value
    }

    /*
     * Returns the stored saved.
     *
     * Takes no parameters.
     *
     * Returns handle.
     */
    handle recall() {
        return(saved)
    }

    /*
     * Creates the Native state by calling the native function
     * cwhip_method_demo_handle_create.
     *
     * Takes no parameters.
     *
     * Returns handle.
     */
    handle create()

    /*
     * Handles consume for this Native by calling the native function
     * cwhip_method_demo_handle_consume.
     *
     * Parameters:
     *   value — handle value.
     *
     * Does not return a value.
     */
    void consume(handle value)

    /*
     * Handles identity for this Native by calling the native function
     * cwhip_method_demo_handle_identity.
     *
     * Parameters:
     *   value — handle value.
     *
     * Returns handle.
     */
    handle identity(handle value)

    /*
     * Handles identity buffer for this Native by calling the native function
     * cwhip_method_demo_identity.
     *
     * Parameters:
     *   value — buffer value.
     *
     * Returns buffer.
     */
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
    }
    except() as message {
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
