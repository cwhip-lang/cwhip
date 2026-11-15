/*
 * tests/functional/positive/positive_installed_sqlite_consumer.cw
 *
 * Checks installed sqlite consumer.
 *
 * Created: 2026-10-06
 * Author: chuck
 *
 * Changelog:
 *   2026-10-06  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import sql as SQL
import sqlite as SQLite
import system as Sys

start {
    String path = Sys.FileSystem().tempFile()
    SQLite.Connection sqlite = SQLite.Connection(path)
    SQL.Connection database = sqlite
    print(database.isOpen())
    print(database.execute("CREATE TABLE sample (value INTEGER)"))

    SQL.Statement insert = database.prepare("INSERT INTO sample VALUES (?)")
    print(insert != null)
    print(insert.bind(1, SQL.Value(int64(42))))
    print(insert.step() == false)
    print(insert.isDone())
    print(insert.close())

    SQL.Statement query = database.prepare("SELECT value FROM sample")
    print(query.step())
    print(query.value(0).asInteger() == 42)
    print(query.close())
    print(database.close())
    print(Sys.FileSystem().remove(path))
}
