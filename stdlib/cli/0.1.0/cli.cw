# Registration-based command-line option parsing for Cwhip applications.
# Mirrors the compiler's C++ CommandLine, with multiple named positionals and
# optional capture of argv after `--` into remainderValues().
import system as Sys

namespace Cli {
    class ValueType {
        int64 FLAG = 0
        int64 COUNTER = 1
        int64 STRING = 2
        int64 NUMBER = 3
    }

    class Action {
        int64 NONE = 0
        int64 HELP = 1
        int64 VERSION = 2
        # Help and version stop parsing. Any other action keeps parsing so
        # later flags are still checked, and required arguments are not
        # enforced once an action is set.
        int64 DUMP_CONFIG = 3
    }

    class Option {
        String shortName = ""
        String longName = ""
        String name = ""
        String description = ""
        int64 valueType = 0
        bool isList = false
        String listSeparator = ":"
        bool required = false
        bool hasDefault = false
        String defaultValue = ""
        int64 action = 0
    }

    class Positional {
        String name = ""
        String description = ""
        bool required = false
        bool isList = false
    }

    class CommandLine {
        String programName
        String description
        String version
        list options
        list positionals
        dict values
        dict provided
        dict counts
        list positionalValues
        list remainderValues
        int64 action
        bool captureRemainder
        bool remainderMode
        bool positionalOnly
        int64 nextPositional

        CommandLine(String program, String summary, String ver) {
            programName = program
            description = summary
            version = ver
            options = []
            positionals = []
            values = [:]
            provided = [:]
            counts = [:]
            positionalValues = []
            remainderValues = []
            action = Action().NONE
            captureRemainder = false
            remainderMode = false
            positionalOnly = false
            nextPositional = 0
        }

        void setCaptureRemainder(bool enabled) {
            captureRemainder = enabled
        }

        void addOption(Option option) {
            if (option.name.equals("") or (option.longName.equals("") and option.shortName.equals(""))) {
                raise(Exception("command-line options need a value name and an option name"))
            }
            if (option.shortName.length > 1) {
                raise(Exception("command-line short option names must be one character"))
            }
            bool takesValue = option.valueType == ValueType().STRING or option.valueType == ValueType().NUMBER
            if (not takesValue and option.isList) {
                raise(Exception("switch options cannot accept list values"))
            }
            if (option.isList and option.listSeparator.equals("")) {
                raise(Exception("list options need a list separator"))
            }
            int64 index = 0
            while (index < options.length) {
                Option current = options[index] as Option
                if (current.name.equals(option.name)) {
                    raise(Exception("duplicate command-line option"))
                }
                if (not option.longName.equals("") and current.longName.equals(option.longName)) {
                    raise(Exception("duplicate command-line option"))
                }
                if (not option.shortName.equals("") and current.shortName.equals(option.shortName)) {
                    raise(Exception("duplicate command-line option"))
                }
                index = index + 1
            }
            options.append(option)
        }

        void addPositional(Positional positional) {
            if (positional.name.equals("")) {
                raise(Exception("positional arguments need a value name"))
            }
            int64 index = 0
            while (index < positionals.length) {
                Positional current = positionals[index] as Positional
                if (current.name.equals(positional.name)) {
                    raise(Exception("duplicate positional argument"))
                }
                if (current.isList) {
                    raise(Exception("only the last positional argument may be a list"))
                }
                index = index + 1
            }
            positionals.append(positional)
        }

        void parseArgv() {
            list arguments = []
            Sys.Process process = Sys.Process()
            int64 index = 1
            while (index < process.argc()) {
                arguments.append(process.arg(index))
                index = index + 1
            }
            parse(arguments)
        }

        void parse(list arguments) {
            values = [:]
            provided = [:]
            counts = [:]
            positionalValues = []
            remainderValues = []
            action = Action().NONE
            remainderMode = false
            positionalOnly = false
            nextPositional = 0
            int64 optionIndex = 0
            while (optionIndex < options.length) {
                Option option = options[optionIndex] as Option
                if (option.hasDefault) {
                    recordValue(option, option.defaultValue, false)
                }
                optionIndex = optionIndex + 1
            }

            int64 index = 0
            while (index < arguments.length) {
                String argument = arguments[index] as String
                if (not positionalOnly and not remainderMode and argument.equals("--")) {
                    if (captureRemainder) {
                        remainderMode = true
                    } else {
                        positionalOnly = true
                    }
                    index = index + 1
                    continue
                }
                if (not positionalOnly and not remainderMode and argument.length > 1 and argument.startsWith("--")) {
                    int64 separator = argument.find("=")
                    String name = ""
                    String attached = ""
                    bool hasAttached = false
                    if (separator < 0) {
                        name = argument[2..argument.length - 1]
                    } else {
                        name = argument[2..separator - 1]
                        attached = argument[separator + 1..argument.length - 1]
                        hasAttached = true
                    }
                    Option option = findLongOption(name)
                    if (option == null) {
                        raise(Exception(format("unknown option: --{}", name)))
                    }
                    int64 consumed = applyOption(option, hasAttached, attached, arguments, index)
                    if (consumed < 0) {
                        return
                    }
                    index = index + 1 + consumed
                    continue
                }
                if (not positionalOnly and not remainderMode and argument.length > 1 and argument.startsWith("-")) {
                    int64 offset = 1
                    int64 consumedExtra = 0
                    while (offset < argument.length) {
                        String shortName = argument[offset..offset]
                        Option option = findShortOption(shortName)
                        if (option == null) {
                            raise(Exception(format("unknown option: -{}", shortName)))
                        }
                        if ((option.valueType == ValueType().FLAG or option.valueType == ValueType().COUNTER) and option.action == Action().NONE) {
                            bool attachedValue = offset + 1 < argument.length and argument[offset + 1..offset + 1].equals("=")
                            String attached = ""
                            bool hasAttached = false
                            if (attachedValue) {
                                attached = argument[offset + 2..argument.length - 1]
                                hasAttached = true
                            }
                            int64 consumed = applyOption(option, hasAttached, attached,
                                                         arguments, index)
                            if (consumed < 0) {
                                return
                            }
                            if (attachedValue) {
                                break
                            }
                            offset = offset + 1
                            continue
                        }
                        String attached = ""
                        bool hasAttached = false
                        if (offset + 1 < argument.length) {
                            int64 valueStart = offset + 1
                            if (argument[valueStart..valueStart].equals("=")) {
                                valueStart = valueStart + 1
                            }
                            if (valueStart < argument.length) {
                                attached = argument[valueStart..argument.length - 1]
                                hasAttached = true
                            } else {
                                attached = ""
                                hasAttached = true
                            }
                        }
                        int64 consumed = applyOption(option, hasAttached, attached,
                                                     arguments, index)
                        if (consumed < 0) {
                            return
                        }
                        consumedExtra = consumed
                        break
                    }
                    index = index + 1 + consumedExtra
                    continue
                }
                recordPositional(argument)
                index = index + 1
            }

            # An action does not require the remaining arguments.
            if (action != Action().NONE) {
                return
            }
            optionIndex = 0
            while (optionIndex < options.length) {
                Option option = options[optionIndex] as Option
                if (option.required and not wasProvided(option.name)) {
                    raise(Exception(format("required option not found: {}",
                                           displayName(option))))
                }
                optionIndex = optionIndex + 1
            }
            int64 requiredSlots = 0
            int64 positionalIndex = 0
            while (positionalIndex < positionals.length) {
                Positional positional = positionals[positionalIndex] as Positional
                if (positional.required and not positional.isList) {
                    requiredSlots = requiredSlots + 1
                }
                if (positional.required and positional.isList and positionalIndex >= positionalValues.length) {
                    raise(Exception(format("required argument not found: {}",
                                           positional.name)))
                }
                positionalIndex = positionalIndex + 1
            }
            if (requiredSlots > positionalValues.length) {
                Positional missing = positionals[positionalValues.length] as Positional
                raise(Exception(format("required argument not found: {}", missing.name)))
            }
        }


        bool hasKey(dict table, String name) {
            for (key, value in table) {
                if ((key as String).equals(name)) {
                    return(true)
                }
            }
            return(false)
        }

        bool wasProvided(String name) {
            if (hasKey(provided, name) == false) {
                return(false)
            }
            return(provided[name] as bool)
        }

        bool switchValue(String name) {
            return(wasProvided(name))
        }

        int64 count(String name) {
            if (hasKey(counts, name) == false) {
                return(0)
            }
            return(counts[name] as int64)
        }

        bool hasValue(String name) {
            if (hasKey(values, name) == false) {
                return(false)
            }
            list items = values[name] as list
            return(items.length > 0)
        }

        String value(String name) {
            if (not hasValue(name)) {
                return("")
            }
            list items = values[name] as list
            return(items[items.length - 1] as String)
        }

        list valuesFor(String name) {
            if (hasKey(values, name) == false) {
                list empty = []
                return(empty)
            }
            return(values[name] as list)
        }

        bool containsItem(String name, String item) {
            list items = valuesFor(name)
            int64 index = 0
            while (index < items.length) {
                if ((items[index] as String).equals(item)) {
                    return(true)
                }
                index = index + 1
            }
            return(false)
        }

        list allPositionalValues() {
            return(positionalValues)
        }

        list allRemainderValues() {
            return(remainderValues)
        }

        int64 currentAction() {
            return(action)
        }

        String helpText() {
            String output = format("Usage: {} [options]", programName)
            int64 index = 0
            while (index < positionals.length) {
                Positional positional = positionals[index] as Positional
                String open = " ["
                String close = "]"
                if (positional.required) {
                    open = " <"
                    close = ">"
                }
                String suffix = ""
                if (positional.isList) {
                    suffix = "..."
                }
                output = format("{}{}{}{}{}", output, open, positional.name, suffix, close)
                index = index + 1
            }
            if (captureRemainder) {
                output = format("{} [-- <args>...]", output)
            }
            output = format("{}\n\n{}\n\nOptions:\n", output, description)
            index = 0
            while (index < options.length) {
                Option option = options[index] as Option
                String line = "  "
                if (not option.shortName.equals("")) {
                    line = format("{}-{}", line, option.shortName)
                } else {
                    line = format("{}  ", line)
                }
                if (not option.longName.equals("")) {
                    if (not option.shortName.equals("")) {
                        line = format("{}, ", line)
                    } else {
                        line = format("{}  ", line)
                    }
                    line = format("{}--{}", line, option.longName)
                }
                if ((option.valueType == ValueType().STRING or option.valueType == ValueType().NUMBER) and option.action == Action().NONE) {
                    if (option.isList) {
                        line = format("{} <value>...", line)
                    } else {
                        line = format("{} <value>", line)
                    }
                }
                line = format("{}\t{}", line, option.description)
                if (option.valueType == ValueType().COUNTER) {
                    line = format("{} (repeatable)", line)
                }
                if (option.hasDefault) {
                    line = format("{} (default: {})", line, option.defaultValue)
                }
                if (option.required) {
                    line = format("{} (required)", line)
                }
                output = format("{}{}\n", output, line)
                index = index + 1
            }
            index = 0
            while (index < positionals.length) {
                Positional positional = positionals[index] as Positional
                String line = format("  {}\t{}", positional.name, positional.description)
                if (positional.required) {
                    line = format("{} (required)", line)
                }
                output = format("{}{}\n", output, line)
                index = index + 1
            }
            return(output)
        }

        String versionText() {
            return(format("{}: v{}\n", programName, version))
        }

        Option findLongOption(String name) {
            int64 index = 0
            while (index < options.length) {
                Option option = options[index] as Option
                if (not option.longName.equals("") and option.longName.equals(name)) {
                    return(option)
                }
                index = index + 1
            }
            return(null)
        }

        Option findShortOption(String name) {
            int64 index = 0
            while (index < options.length) {
                Option option = options[index] as Option
                if (not option.shortName.equals("") and option.shortName.equals(name)) {
                    return(option)
                }
                index = index + 1
            }
            return(null)
        }

        String displayName(Option option) {
            if (option.longName.equals("")) {
                return(format("-{}", option.shortName))
            }
            return(format("--{}", option.longName))
        }

        list splitListValue(String value, String separator) {
            list result = []
            int64 begin = 0
            while (begin <= value.length) {
                String tail = ""
                if (begin < value.length) {
                    tail = value[begin..value.length - 1]
                }
                int64 relative = -1
                if (not tail.equals("")) {
                    relative = tail.find(separator)
                }
                int64 separatorAt = -1
                if (relative >= 0) {
                    separatorAt = begin + relative
                }
                int64 end = value.length
                if (separatorAt >= 0) {
                    end = separatorAt
                }
                if (end <= begin) {
                    result.append("")
                } else {
                    result.append(value[begin..end - 1])
                }
                if (separatorAt < 0 or separatorAt + 1 == value.length) {
                    break
                }
                begin = separatorAt + 1
            }
            return(result)
        }

        bool isNumber(String item) {
            if (item.equals("")) {
                return(false)
            }
            try {
                item.toInt64()
                return(true)
            } except() {
                return(false)
            }
        }

        void recordValue(Option option, String value, bool providedFlag) {
            list destination = []
            if (hasKey(values, option.name) and option.isList) {
                destination = values[option.name] as list
            }
            list items = []
            if (option.isList) {
                items = splitListValue(value, option.listSeparator)
            } else {
                items.append(value)
            }
            if (option.valueType == ValueType().NUMBER) {
                int64 itemIndex = 0
                while (itemIndex < items.length) {
                    String item = items[itemIndex] as String
                    if (not isNumber(item)) {
                        raise(Exception(format("option {} requires a number",
                                               displayName(option))))
                    }
                    itemIndex = itemIndex + 1
                }
            }
            int64 itemIndex = 0
            while (itemIndex < items.length) {
                destination.append(items[itemIndex])
                itemIndex = itemIndex + 1
            }
            values[option.name] = destination
            if (providedFlag) {
                provided[option.name] = true
            }
        }

        void recordPositional(String value) {
            if (remainderMode) {
                remainderValues.append(value)
                return
            }
            if (positionals.length == 0) {
                raise(Exception(format("unexpected positional argument: {}", value)))
            }
            if (nextPositional >= positionals.length) {
                Positional last = positionals[positionals.length - 1] as Positional
                if (last.isList) {
                    positionalValues.append(value)
                    return
                }
                raise(Exception(format("unexpected positional argument: {}", value)))
            }
            Positional positional = positionals[nextPositional] as Positional
            positionalValues.append(value)
            if (not positional.isList) {
                nextPositional = nextPositional + 1
            }
        }

        # Returns -1 to stop parsing (help/version), 0 if no following argv was
        # consumed, or 1 if the next argv entry was taken as the option value.
        int64 applyOption(Option option, bool hasAttached, String attached,
                          list arguments, int64 index) {
            if ((option.action == Action().HELP) or (option.action == Action().VERSION)) {
                if (hasAttached) {
                    raise(Exception(format("option {} does not accept an argument",
                                           displayName(option))))
                }
                action = option.action
                return(-1)
            }
            if (option.action != Action().NONE) {
                if (hasAttached) {
                    raise(Exception(format("option {} does not accept an argument",
                                           displayName(option))))
                }
                action = option.action
                provided[option.name] = true
                return(0)
            }
            if (option.valueType == ValueType().FLAG) {
                if (hasAttached) {
                    raise(Exception(format("option {} does not accept an argument",
                                           displayName(option))))
                }
                provided[option.name] = true
                return(0)
            }
            if (option.valueType == ValueType().COUNTER) {
                if (hasAttached) {
                    raise(Exception(format("option {} does not accept an argument",
                                           displayName(option))))
                }
                provided[option.name] = true
                counts[option.name] = count(option.name) + 1
                return(0)
            }
            String argument = ""
            int64 consumed = 0
            if (hasAttached) {
                argument = attached
            } else {
                if (index + 1 >= arguments.length) {
                    raise(Exception(format("option {} requires an argument",
                                           displayName(option))))
                }
                argument = arguments[index + 1] as String
                consumed = 1
            }
            recordValue(option, argument, true)
            return(consumed)
        }
    }
}
