/*
 * tools/cwhip-format.cw — Implementation of the cwhip-format tool.
 *
 * Created: 2026-11-13
 * Author: Auto
 *
 * Changelog:
 *   2026-11-13  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 *   2026-11-15  Print in-place file names with -v.
 *   2026-11-15  Add a dry run, standard input, and a line range.
 */

import cli as Cli
import system as Sys

/*
 * FormatTool is a class.
 *
 * Its methods include version, builtinConfig, formatFile.
 */
class FormatTool {
    public:
    /*
     * Handles version for this FormatTool by calling the native function
     * cwhip_format_version.
     *
     * Takes no parameters.
     *
     * Returns String.
     */
    String version()

    /*
     * Handles builtin config for this FormatTool by calling the native
     * function cwhip_format_builtin_config.
     *
     * Takes no parameters.
     *
     * Returns String.
     */
    String builtinConfig()

    /*
     * Formats file for this FormatTool by calling the native function
     * cwhip_format_file.
     *
     * Parameters:
     *   path — String path.
     *   stylePath — String style path.
     *   inPlace — bool in place.
     *   dryRun — bool dry run. Exits non-zero when the file would change.
     *   lines — String lines. Empty formats the whole file. Otherwise
     *     START:END, 1-based and inclusive.
     *
     * Returns int64.
     */
    int64 formatFile(String path, String stylePath, bool inPlace, bool dryRun, String lines)
}

String FormatTool.version() from "cwhip_format_version"
String FormatTool.builtinConfig() from "cwhip_format_builtin_config"
int64 FormatTool.formatFile(String path, String stylePath, bool inPlace, bool dryRun, String lines) from "cwhip_format_file"

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

    Cli.Option verbose = Cli.Option()
    verbose.shortName = "v"
    verbose.longName = "verbose"
    verbose.name = "verbose"
    verbose.description = "Print each file name when rewriting in place"
    command.addOption(verbose)

    Cli.Option dryRun = Cli.Option()
    dryRun.longName = "dry-run"
    dryRun.name = "dry-run"
    dryRun.description = "Exit non-zero when a file would change, and do not write"
    command.addOption(dryRun)

    Cli.Option lines = Cli.Option()
    lines.longName = "lines"
    lines.name = "lines"
    lines.description = "Format only these 1-based lines, START:END"
    lines.valueType = Cli.ValueType().STRING
    command.addOption(lines)

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
    }
    except(Exception) as error {
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

    bool dry = command.switchValue("dry-run")
    bool rewrite = command.switchValue("in-place") and not dry
    bool showNames = command.switchValue("verbose")
    String lineRange = ""
    if (command.wasProvided("lines")) {
        lineRange = command.value("lines")
    }
    list files = command.allPositionalValues()
    int64 index = 0
    int64 status = 0
    while (index < files.length) {
        String path = files[index] as String
        if (rewrite and showNames) {
            Sys.System().io().writeErrorLine(path)
        }
        int64 result = tool.formatFile(path, "", rewrite, dry, lineRange)
        if (result != 0 and status != 2) {
            status = result
        }
        index = index + 1
    }

    Sys.System().exit(status)
}
