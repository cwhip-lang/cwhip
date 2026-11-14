import cli as Cli
import system as Sys

class FormatTool {
    String version()
    String builtinConfig()
    int64 formatFile(String path, String stylePath, bool inPlace)
}

String FormatTool.version() from "cwhip_format_version"
String FormatTool.builtinConfig() from "cwhip_format_builtin_config"
int64 FormatTool.formatFile(String path, String stylePath, bool inPlace) from "cwhip_format_file"

start {
    FormatTool tool = FormatTool()
    Cli.CommandLine command = Cli.CommandLine("cwhip-format", "Format Cwhip source", tool.version())

    Cli.Option help = Cli.Option()
    help.shortName = "h"
    help.longName = "help"
    help.name = "help"
    help.description = "Print this helpful information"
    help.action = Cli.Action().HELP
    command.addOption(help)

    Cli.Option version = Cli.Option()
    version.shortName = "V"
    version.longName = "version"
    version.name = "version"
    version.description = "Show the program version"
    version.action = Cli.Action().VERSION
    command.addOption(version)

    Cli.Option inPlace = Cli.Option()
    inPlace.shortName = "i"
    inPlace.longName = "in-place"
    inPlace.name = "in-place"
    inPlace.description = "Rewrite each file in place"
    command.addOption(inPlace)

    Cli.Option dumpConfig = Cli.Option()
    dumpConfig.longName = "dump-config"
    dumpConfig.name = "dump-config"
    dumpConfig.description = "Write the built-in default configuration"
    dumpConfig.action = Cli.Action().DUMP_CONFIG
    command.addOption(dumpConfig)

    Cli.Positional file = Cli.Positional()
    file.name = "file"
    file.description = "Cwhip source file"
    file.required = true
    file.isList = true
    command.addPositional(file)

    try {
        command.parseArgv()
    } except(Exception) as error {
        Sys.System().io().writeError(error.message)
        Sys.System().io().writeError("\n")
        Sys.System().io().writeError(command.helpText())
        Sys.System().exit(2)
    }

    if (command.currentAction() == Cli.Action().HELP) {
        Sys.System().io().write(command.helpText())
        Sys.System().exit(0)
    }
    if (command.currentAction() == Cli.Action().VERSION) {
        Sys.System().io().write(command.versionText())
        Sys.System().exit(0)
    }
    if (command.currentAction() == Cli.Action().DUMP_CONFIG) {
        Sys.System().io().write(tool.builtinConfig())
        Sys.System().exit(0)
    }

    bool rewrite = command.switchValue("in-place")
    list files = command.allPositionalValues()
    int64 index = 0
    int64 status = 0
    while (index < files.length) {
        String path = files[index] as String
        int64 result = tool.formatFile(path, "", rewrite)
        if (result != 0) {
            status = 1
        }
        index = index + 1
    }
    Sys.System().exit(status)
}
