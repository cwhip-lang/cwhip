/*
 * tests/functional/positive/positive_stdlib_sqlite.cw — Checks stdlib sqlite.
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
    SQLite.Connection temporaryPath = SQLite.Connection("")
    print(temporaryPath.isOpen())
    print(temporaryPath.close())

    String path = Sys.FileSystem().tempFile()
    SQLite.Connection sqlite = SQLite.Connection(path)
    SQL.Connection database = sqlite
    print(database.isOpen())
    print(database.execute(""))
    SQL.Statement emptySql = database.prepare("")
    print(emptySql == null)
    print(database.error().length > 0)
    print(sqlite.setBusyTimeout(-1) == false)
    print(database.error().length > 0)
    print(sqlite.setBusyTimeout(1000))
    print(database.execute("PRAGMA foreign_keys = ON"))
    print(database.execute(
            "CREATE TABLE payload (n, i, r, text_value, blob_value)"))
    print(database.execute("CREATE TABLE affinity (value INTEGER)"))
    print(database.execute("INSERT INTO affinity VALUES (1.5)"))

    SQL.Statement affinity = database.prepare("SELECT value FROM affinity")
    print(affinity.step())
    SQL.Value affinityValue = affinity.value(0)
    print(affinityValue.kind() == 2)
    print(affinityValue.asReal() == 1.5)
    print(affinity.close())

    SQL.Statement insert = database.prepare("INSERT INTO payload VALUES (?, ?, ?, ?, ?)")
    buffer bytes = buffer[0, 255, 65]
    String injection = "'); DROP TABLE payload; --"
    print(insert.bind(1, SQL.Value()))
    print(insert.bind(2, SQL.Value(9223372036854775807)))
    print(insert.bind(3, SQL.Value(3.25)))
    print(insert.bind(4, SQL.Value(injection)))
    print(insert.bind(5, SQL.Value(bytes)))
    print(insert.step() == false)
    print(insert.isDone())
    print(insert.step() == false)
    print(insert.failed() == false)
    print(insert.close())

    SQL.Statement query = database.prepare("SELECT n, i, r, text_value, blob_value FROM payload")
    print(query.step())
    print(database.close() == false)
    print(database.isOpen())
    SQL.Value nullValue = query.value(0)
    SQL.Value integerValue = query.value(1)
    SQL.Value realValue = query.value(2)
    SQL.Value textValue = query.value(3)
    SQL.Value blobValue = query.value(4)
    print(nullValue.isNull())
    print(integerValue.kind() == 1)
    print(integerValue.asInteger() == 9223372036854775807)
    print(realValue.kind() == 2)
    print(realValue.asReal() == 3.25)
    print(textValue.kind() == 3)
    print(textValue.asText().equals(injection))
    print(blobValue.kind() == 4)
    buffer resultBytes = blobValue.asBlob()
    print(resultBytes.length == 3)
    print(resultBytes[0] == 0u)
    print(resultBytes[1] == 255u)
    print(query.step() == false)
    print(query.isDone())
    print(query.close())

    SQL.Statement emptyValues = database.prepare("SELECT ?, ?")
    buffer emptyBlob = buffer[]
    print(emptyValues.bind(1, SQL.Value("")))
    print(emptyValues.bind(2, SQL.Value(emptyBlob)))
    print(emptyValues.step())
    SQL.Value emptyTextValue = emptyValues.value(0)
    SQL.Value emptyBlobValue = emptyValues.value(1)
    print(emptyTextValue.kind() == 3)
    print(emptyTextValue.asText().length == 0)
    print(emptyBlobValue.kind() == 4)
    print(emptyBlobValue.asBlob().length == 0)
    print(emptyValues.close())

    SQL.Statement empty = database.prepare("SELECT i FROM payload WHERE 0")
    print(empty.step() == false)
    print(empty.isDone())
    print(empty.step() == false)
    print(empty.failed() == false)
    print(empty.close())

    SQL.Statement invalid = database.prepare("SELECT FROM")
    print(invalid == null)
    print(database.error().length > 0)
    print(database.execute("SELECT * FROM missing_table") == false)
    print(database.error().length > 0)

    bool mismatchCaught = false
    try {
        nullValue.asInteger()
    }
    except() {
        mismatchCaught = true
    }
    print(mismatchCaught)

    SQL.Transaction transaction = database.beginTransaction()
    print(transaction.isActive())
    print(database.close() == false)
    print(database.isOpen())
    print(database.execute("ROLLBACK"))
    print(database.close() == false)
    print(transaction.isActive() == false)
    print(transaction.commit() == false)
    print(transaction.rollback() == false)
    print(database.execute(
            "INSERT INTO payload VALUES (NULL, 7, 2.5, 'rollback', X'01')"))
    print(transaction.close())
    print(transaction.isActive() == false)
    SQL.Transaction committed = database.beginTransaction()
    print(database.execute(
            "INSERT INTO payload VALUES (NULL, 8, 3.5, 'commit', X'02')"))
    print(committed.commit())
    print(committed.isActive() == false)
    SQL.Statement count = database.prepare("SELECT count(*) FROM payload")
    print(count.step())
    print(count.value(0).asInteger() == 3)
    print(count.step() == false)
    print(count.step() == false)
    print(count.close())

    print(database.close())
    print(database.close())
    print(Sys.FileSystem().remove(path))
}
