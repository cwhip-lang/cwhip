# Exercises the stdlib cli package: attached shorts, list separators, defaults,
# help/version actions, counters, multiple positionals, and remainder capture.
import cli as Cli

class Fixture {
    public:
    Cli.CommandLine makeParser() {
        Cli.CommandLine commandLine = Cli.CommandLine("test", "test options", "1.2")
        Cli.Option alpha = Cli.Option()
        alpha.shortName = "a"
        alpha.longName = "alpha"
        alpha.name = "alpha"
        commandLine.addOption(alpha)

        Cli.Option beta = Cli.Option()
        beta.shortName = "b"
        beta.longName = "beta"
        beta.name = "beta"
        commandLine.addOption(beta)

        Cli.Option path = Cli.Option()
        path.shortName = "p"
        path.longName = "path"
        path.name = "path"
        path.valueType = Cli.ValueType().STRING
        path.isList = true
        commandLine.addOption(path)

        Cli.Option output = Cli.Option()
        output.shortName = "o"
        output.longName = "output"
        output.name = "output"
        output.valueType = Cli.ValueType().STRING
        output.hasDefault = true
        output.defaultValue = "default.out"
        commandLine.addOption(output)

        Cli.Option count = Cli.Option()
        count.longName = "count"
        count.name = "count"
        count.valueType = Cli.ValueType().NUMBER
        count.required = true
        commandLine.addOption(count)

        Cli.Option help = Cli.Option()
        help.longName = "help"
        help.name = "help"
        help.action = Cli.Action().HELP
        commandLine.addOption(help)

        Cli.Positional source = Cli.Positional()
        source.name = "source"
        source.description = "source file"
        source.required = true
        source.isList = true
        commandLine.addPositional(source)
        return(commandLine)
    }
}

start {
    Fixture fixture = Fixture()
    Cli.CommandLine commandLine = fixture.makeParser()
    list args = ["-ab", "-p", "one:two", "-pthree", "-o=first",
                 "--output=last", "--count", "-5", "first.cw",
                 "--", "-input.cw"]
    commandLine.parse(args)
    print(commandLine.switchValue("alpha") and commandLine.switchValue("beta"))
    list paths = commandLine.valuesFor("path")
    print(paths.length == 3)
    print((paths[0] as String).equals("one"))
    print((paths[1] as String).equals("two"))
    print((paths[2] as String).equals("three"))
    print(commandLine.value("output").equals("last"))
    print(commandLine.wasProvided("output"))
    print(commandLine.value("count").equals("-5"))
    list positionals = commandLine.allPositionalValues()
    print(positionals.length == 2)
    print((positionals[0] as String).equals("first.cw"))
    print((positionals[1] as String).equals("-input.cw"))

    commandLine = fixture.makeParser()
    list helpArgs = ["--help"]
    commandLine.parse(helpArgs)
    print(commandLine.currentAction() == Cli.Action().HELP)
    print(commandLine.value("output").equals("default.out"))
    print(not commandLine.wasProvided("output"))
    print(commandLine.helpText().contains("--count <value>"))
    print(commandLine.versionText().equals("test: v1.2\n"))

    commandLine = fixture.makeParser()
    bool failedRequired = false
    try {
        list onlySource = ["source.cw"]
        commandLine.parse(onlySource)
    } except() as error {
        failedRequired = format("{}", error).contains("required option")
    }
    print(failedRequired)

    commandLine = fixture.makeParser()
    list multi = ["--count", "1", "source.cw", "other.cw"]
    commandLine.parse(multi)
    print(commandLine.allPositionalValues().length == 2)

    bool unknown = false
    try {
        commandLine = fixture.makeParser()
        list bad = ["--unknown", "--count", "1", "x"]
        commandLine.parse(bad)
    } except() as error {
        unknown = format("{}", error).contains("unknown option")
    }
    print(unknown)

    Cli.CommandLine counters = Cli.CommandLine("test", "test options", "1.2")
    Cli.Option verbose = Cli.Option()
    verbose.shortName = "v"
    verbose.name = "verbose"
    verbose.valueType = Cli.ValueType().COUNTER
    counters.addOption(verbose)
    Cli.Option quiet = Cli.Option()
    quiet.shortName = "q"
    quiet.name = "quiet"
    counters.addOption(quiet)
    Cli.Option trace = Cli.Option()
    trace.shortName = "t"
    trace.longName = "trace"
    trace.name = "trace"
    trace.valueType = Cli.ValueType().STRING
    trace.isList = true
    trace.listSeparator = ","
    counters.addOption(trace)
    list counterArgs = ["-vv", "-qv", "-t", "a,b", "--trace=c:d", "-te"]
    counters.parse(counterArgs)
    print(counters.count("verbose") == 3)
    print(counters.switchValue("quiet"))
    list traces = counters.valuesFor("trace")
    print(traces.length == 4)
    print((traces[0] as String).equals("a"))
    print((traces[1] as String).equals("b"))
    print((traces[2] as String).equals("c:d"))
    print((traces[3] as String).equals("e"))

    Cli.CommandLine multiPos = Cli.CommandLine("gen", "generator", "1.0")
    Cli.Positional grammar = Cli.Positional()
    grammar.name = "grammar"
    grammar.description = "grammar file"
    grammar.required = true
    multiPos.addPositional(grammar)
    Cli.Positional outputPos = Cli.Positional()
    outputPos.name = "output"
    outputPos.description = "output file"
    multiPos.addPositional(outputPos)
    list two = ["a.cpg", "out.cw"]
    multiPos.parse(two)
    print(multiPos.allPositionalValues().length == 2)
    print((multiPos.allPositionalValues()[0] as String).equals("a.cpg"))
    print((multiPos.allPositionalValues()[1] as String).equals("out.cw"))

    Cli.CommandLine remainder = Cli.CommandLine("dbg", "debugger", "1.0")
    remainder.setCaptureRemainder(true)
    Cli.Positional target = Cli.Positional()
    target.name = "target"
    target.description = "program"
    remainder.addPositional(target)
    list remArgs = ["prog", "--", "one", "two"]
    remainder.parse(remArgs)
    print(remainder.allPositionalValues().length == 1)
    print((remainder.allPositionalValues()[0] as String).equals("prog"))
    print(remainder.allRemainderValues().length == 2)
    print((remainder.allRemainderValues()[0] as String).equals("one"))
    print((remainder.allRemainderValues()[1] as String).equals("two"))
}
