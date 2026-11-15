/*
 * tests/functional/negative/negative_sqlite_statement_handle_constructor.c
 * w
 *
 * Rejects sqlite statement handle constructor.
 *
 * Created: 2026-10-06
 * Author: chuck
 *
 * Changelog:
 *   2026-10-06  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import sqlite as SQLite

start {
    handle raw = null
    SQLite.Statement statement = SQLite.Statement(raw)
}
