class OutOfLine {
    public:
    OutOfLine(int64 value)
    OutOfLine(strg value)
}

OutOfLine OutOfLine.OutOfLine(int64 value) {
    print("out int")
}

OutOfLine OutOfLine.OutOfLine(strg value) {
    print("out string")
}

start {
    OutOfLine integer = OutOfLine(1)
    OutOfLine text = OutOfLine("value")
}
