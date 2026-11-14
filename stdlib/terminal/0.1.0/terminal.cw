namespace Terminal {
    class Terminal {
        public:
        bool isInteractive()
        bool isOutputInteractive()
        int64 columns()
        int64 rows()
        bool supportsColor()
    }

    bool Terminal.isInteractive() from "cwhip_terminal_stdin_interactive"
    bool Terminal.isOutputInteractive() from "cwhip_terminal_stdout_interactive"
    int64 Terminal.columns() from "cwhip_terminal_columns"
    int64 Terminal.rows() from "cwhip_terminal_rows"
    bool Terminal.supportsColor() from "cwhip_terminal_supports_color"
}
