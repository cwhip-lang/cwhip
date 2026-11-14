class IntBox {
    public:
    int64 value

    IntBox(int64 initial) {
        value = initial
    }

    int64 get() {
        return(value)
    }

    int64 echo(int64 argument) {
        return(argument)
    }
}

class Native {
    public:
    int64 marker

    Native(int64 initialMarker) {
        marker = initialMarker
    }

    int64 absolute(int64 value)
}

int64 Native.absolute(int64 value) from "cwhip_method_demo_abs"

start {
    int64 above32 = 2147483648
    int64 minimum = -9223372036854775808
    int64 maximum = 9223372036854775807

    print(above32)
    print(minimum)
    print(maximum)
    print(above32 + 1)
    print(above32 * 2)
    print(minimum < -2147483648)
    print(minimum < maximum)
    print(maximum > above32)
    print(minimum + 1)

    IntBox box = IntBox(maximum)
    print(box.get())
    print(box.echo(minimum))

    Native native = Native(91)
    print(native.absolute(above32))
    print(native.absolute(maximum))

    list values = [minimum, maximum, above32]
    print(values[0])
    print(values[1])
    int64 arrayValue = values[2]
    print(arrayValue)
    try {
        int64 invalidIndex = values[4294967296]
        print("unexpected list index")
    } except(Exception) as error {
        print(error.message)
    }

    dict bounds = ["minimum": minimum, "maximum": maximum]
    print(bounds["minimum"])
    print(bounds["maximum"])

    strg minText = "-9223372036854775808"
    strg maxText = "9223372036854775807"
    print(minText.toInt64())
    print(maxText.toInt64())

    try {
        strg aboveMaxText = "9223372036854775808"
        print(aboveMaxText.toInt64())
    } except() as error {
        print(error)
    }

    try {
        strg belowMinText = "-9223372036854775809"
        print(belowMinText.toInt64())
    } except() as error {
        print(error)
    }
}
