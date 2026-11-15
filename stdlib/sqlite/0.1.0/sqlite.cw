/*
 * stdlib/sqlite/0.1.0/sqlite.cw — sqlite package implementation.
 *
 * Created: 2026-10-06
 * Author: chuck
 *
 * Changelog:
 *   2026-10-06  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import sql as SQL

namespace SQLite {

    /*
     * Connection is a class derived from SQL.Connection in this
     * standard-library package.
     *
     * Its methods include _nativeOpen, _nativeClose, _nativeReleaseConnection,
     * _nativeConnectionError, _nativeExecute, _nativePrepare, and 8 more.
     */
    class Connection : SQL.Connection {
        private:
        handle _native

        /*
         * Handles native open for this Connection by calling the native
         * function cwhip_sqlite_open.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns handle.
         */
        handle _nativeOpen(String path)

        /*
         * Handles native close for this Connection by calling the native
         * function cwhip_sqlite_close.
         *
         * Parameters:
         *   connection — handle connection.
         *
         * Returns bool.
         */
        bool _nativeClose(handle connection)

        /*
         * Handles native release connection for this Connection by calling the
         * native function cwhip_sqlite_release_connection.
         *
         * Parameters:
         *   connection — handle connection.
         *
         * Does not return a value.
         */
        void _nativeReleaseConnection(handle connection)

        /*
         * Handles native connection error for this Connection by calling the
         * native function cwhip_sqlite_connection_error.
         *
         * Parameters:
         *   connection — handle connection.
         *
         * Returns String.
         */
        String _nativeConnectionError(handle connection)

        /*
         * Handles native execute for this Connection by calling the native
         * function cwhip_sqlite_execute.
         *
         * Parameters:
         *   connection — handle connection.
         *   sql — String sql.
         *
         * Returns bool.
         */
        bool _nativeExecute(handle connection, String sql)

        /*
         * Handles native prepare for this Connection by calling the native
         * function cwhip_sqlite_prepare.
         *
         * Parameters:
         *   connection — handle connection.
         *   target — Statement target.
         *   sql — String sql.
         *
         * Returns bool.
         */
        bool _nativePrepare(handle connection, Statement target, String sql)

        /*
         * Handles native busy timeout for this Connection by calling the
         * native function cwhip_sqlite_busy_timeout.
         *
         * Parameters:
         *   connection — handle connection.
         *   milliseconds — int64 milliseconds.
         *
         * Returns bool.
         */
        bool _nativeBusyTimeout(handle connection, int64 milliseconds)

        /*
         * Handles native begin transaction for this Connection by calling the
         * native function cwhip_sqlite_begin_transaction.
         *
         * Parameters:
         *   connection — handle connection.
         *   target — Transaction target.
         *
         * Returns bool.
         */
        bool _nativeBeginTransaction(handle connection, Transaction target)

        public:
        /*
         * Constructs a Connection and stores _native.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns the constructed Connection.
         */
        Connection(String path) {
            _native = _nativeOpen(path)
        }

        /*
         * Returns _native != null.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool isOpen() {
            return(_native != null)
        }

        /*
         * Returns _nativeConnectionError(_native).
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String error() {
            return(_nativeConnectionError(_native))
        }

        /*
         * Handles execute for this Connection. Raises Exception when the call
         * is not valid (SQLite connection is closed).
         *
         * Parameters:
         *   sql — String sql.
         *
         * Returns bool.
         */
        bool execute(String sql) {
            if (_native == null) {
                raise(Exception("SQLite connection is closed"))
            }
            return(_nativeExecute(_native, sql))
        }

        SQL.Statement prepare(String sql) {
            if (_native == null) {
                raise(Exception("SQLite connection is closed"))
            }
            Statement result = Statement()
            if (!_nativePrepare(_native, result, sql)) {
                return(null)
            }
            return(result)
        }

        /*
         * Sets busy timeout for this Connection. Raises Exception when the
         * call is not valid (SQLite connection is closed).
         *
         * Parameters:
         *   milliseconds — int64 milliseconds.
         *
         * Returns bool.
         */
        bool setBusyTimeout(int64 milliseconds) {
            if (_native == null) {
                raise(Exception("SQLite connection is closed"))
            }
            return(_nativeBusyTimeout(_native, milliseconds))
        }

        SQL.Transaction beginTransaction() {
            if (_native == null) {
                raise(Exception("SQLite connection is closed"))
            }
            Transaction transaction = Transaction()
            if (!_nativeBeginTransaction(_native, transaction)) {
                raise(Exception(_nativeConnectionError(_native)))
            }
            return(transaction)
        }

        /*
         * Closes the Connection state.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool close() {
            if (_native == null) {
                return(true)
            }
            bool closed = _nativeClose(_native)
            if (closed) {
                _native = null
            }
            return(closed)
        }

        /*
         * Destroys this object and runs the cleanup owned by the instance.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        destroy {
            if (_native != null) {
                _nativeReleaseConnection(_native)
                _native = null
            }

        }
    }

    /*
     * Statement is a class derived from SQL.Statement in this standard-library
     * package.
     *
     * Its methods include _nativeExists, _nativeFinalize, _nativeStep,
     * _nativeStatementError, _nativeBindNull, _nativeBindInteger, and 16 more.
     */
    class Statement : SQL.Statement {
        private:
        bool _hasRow
        bool _done
        bool _failed
        bool _hasStepped

        private:
        /*
         * Handles native exists for this Statement by calling the native
         * function cwhip_sqlite_statement_exists.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool _nativeExists()

        /*
         * Handles native finalize for this Statement by calling the native
         * function cwhip_sqlite_finalize.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool _nativeFinalize()

        /*
         * Handles native step for this Statement by calling the native
         * function cwhip_sqlite_step.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 _nativeStep()

        /*
         * Handles native statement error for this Statement by calling the
         * native function cwhip_sqlite_statement_error.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String _nativeStatementError()

        /*
         * Handles native bind null for this Statement by calling the native
         * function cwhip_sqlite_bind_null.
         *
         * Parameters:
         *   index — int64 index.
         *
         * Returns bool.
         */
        bool _nativeBindNull(int64 index)

        /*
         * Handles native bind integer for this Statement by calling the native
         * function cwhip_sqlite_bind_integer.
         *
         * Parameters:
         *   index — int64 index.
         *   value — int64 value.
         *
         * Returns bool.
         */
        bool _nativeBindInteger(int64 index, int64 value)

        /*
         * Handles native bind real for this Statement by calling the native
         * function cwhip_sqlite_bind_real.
         *
         * Parameters:
         *   index — int64 index.
         *   value — fp64 value.
         *
         * Returns bool.
         */
        bool _nativeBindReal(int64 index, fp64 value)

        /*
         * Handles native bind text for this Statement by calling the native
         * function cwhip_sqlite_bind_text.
         *
         * Parameters:
         *   index — int64 index.
         *   value — String value.
         *
         * Returns bool.
         */
        bool _nativeBindText(int64 index, String value)

        /*
         * Handles native bind blob for this Statement by calling the native
         * function cwhip_sqlite_bind_blob.
         *
         * Parameters:
         *   index — int64 index.
         *   value — buffer value.
         *
         * Returns bool.
         */
        bool _nativeBindBlob(int64 index, buffer value)

        /*
         * Handles native column type for this Statement by calling the native
         * function cwhip_sqlite_column_type.
         *
         * Parameters:
         *   index — int64 index.
         *
         * Returns int64.
         */
        int64 _nativeColumnType(int64 index)

        /*
         * Handles native column integer for this Statement by calling the
         * native function cwhip_sqlite_column_integer.
         *
         * Parameters:
         *   index — int64 index.
         *
         * Returns int64.
         */
        int64 _nativeColumnInteger(int64 index)

        /*
         * Handles native column real for this Statement by calling the native
         * function cwhip_sqlite_column_real.
         *
         * Parameters:
         *   index — int64 index.
         *
         * Returns fp64.
         */
        fp64 _nativeColumnReal(int64 index)

        /*
         * Handles native column text for this Statement by calling the native
         * function cwhip_sqlite_column_text.
         *
         * Parameters:
         *   index — int64 index.
         *
         * Returns String.
         */
        String _nativeColumnText(int64 index)

        /*
         * Handles native column blob for this Statement by calling the native
         * function cwhip_sqlite_column_blob.
         *
         * Parameters:
         *   index — int64 index.
         *
         * Returns buffer.
         */
        buffer _nativeColumnBlob(int64 index)

        public:
        /*
         * Constructs a Statement and stores _hasRow, _done, _failed,
         * _hasStepped.
         *
         * Takes no parameters.
         *
         * Returns the constructed Statement.
         */
        Statement() {
            _hasRow = false
            _done = false
            _failed = false
            _hasStepped = false
        }

        /*
         * Returns _nativeStatementError().
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String error() {
            return(_nativeStatementError())
        }

        /*
         * Binds the Statement state. Raises Exception when the call is not
         * valid (SQLite statement is not prepared or has been finalized;
         * SQLite parameters must be bound before stepping; Invalid SQL value
         * kind).
         *
         * Parameters:
         *   index — int64 index.
         *   value — SQL.Value value.
         *
         * Returns bool.
         */
        bool bind(int64 index, SQL.Value value) {
            if (!_nativeExists()) {
                raise(Exception(
                        "SQLite statement is not prepared or has been finalized"))
            }
            if (_hasStepped) {
                raise(Exception(
                        "SQLite parameters must be bound before stepping"))
            }
            if (value.kind() == 0) {
                return(_nativeBindNull(index))
            }
            if (value.kind() == 1) {
                return(_nativeBindInteger(index, value.asInteger()))
            }
            if (value.kind() == 2) {
                return(_nativeBindReal(index, value.asReal()))
            }
            if (value.kind() == 3) {
                return(_nativeBindText(index, value.asText()))
            }
            if (value.kind() == 4) {
                return(_nativeBindBlob(index, value.asBlob()))
            }
            raise(Exception("Invalid SQL value kind"))
        }

        /*
         * Handles step for this Statement. Raises Exception when the call is
         * not valid (SQLite statement is not prepared or has been finalized).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool step() {
            if (!_nativeExists()) {
                raise(Exception(
                        "SQLite statement is not prepared or has been finalized"))
            }
            if (_done || _failed) {
                return(false)
            }
            int64 status = _nativeStep()
            _hasStepped = true
            _hasRow = status == 1
            _done = status == 0
            _failed = status < 0
            return(_hasRow)
        }

        /*
         * Returns the stored _hasRow.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool hasRow() {
            return(_hasRow)
        }

        /*
         * Returns the stored _done.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool isDone() {
            return(_done)
        }

        /*
         * Returns the stored _failed.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool failed() {
            return(_failed)
        }

        SQL.Value value(int64 zeroBasedColumnIndex) {
            if (!_nativeExists()) {
                raise(Exception(
                        "SQLite statement is not prepared or has been finalized"))
            }
            if (!_hasRow) {
                raise(Exception("SQLite statement has no current row"))
            }
            int64 kind = _nativeColumnType(zeroBasedColumnIndex)
            if (kind == 0) {
                return(SQL.Value())
            }
            if (kind == 1) {
                return(SQL.Value(_nativeColumnInteger(zeroBasedColumnIndex)))
            }
            if (kind == 2) {
                return(SQL.Value(_nativeColumnReal(zeroBasedColumnIndex)))
            }
            if (kind == 3) {
                return(SQL.Value(_nativeColumnText(zeroBasedColumnIndex)))
            }
            if (kind == 4) {
                return(SQL.Value(_nativeColumnBlob(zeroBasedColumnIndex)))
            }
            raise(Exception("SQLite returned an unsupported storage class"))
        }

        /*
         * Closes the Statement state.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool close() {
            bool finalized = _nativeFinalize()
            _hasRow = false
            _done = true
            return(finalized)
        }

        /*
         * Destroys this object and runs the cleanup owned by the instance.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        destroy {
            close()
        }

    }

    /*
     * Transaction is a class derived from SQL.Transaction in this
     * standard-library package.
     *
     * Its methods include _nativeExists, _nativeActive, _nativeCommit,
     * _nativeRollback, _nativeClose, constructor, and 4 more.
     */
    class Transaction : SQL.Transaction {
        private:
        bool _active

        /*
         * Handles native exists for this Transaction by calling the native
         * function cwhip_sqlite_transaction_exists.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool _nativeExists()

        /*
         * Handles native active for this Transaction by calling the native
         * function cwhip_sqlite_transaction_active.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool _nativeActive()

        /*
         * Handles native commit for this Transaction by calling the native
         * function cwhip_sqlite_transaction_commit.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool _nativeCommit()

        /*
         * Handles native rollback for this Transaction by calling the native
         * function cwhip_sqlite_transaction_rollback.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool _nativeRollback()

        /*
         * Handles native close for this Transaction by calling the native
         * function cwhip_sqlite_transaction_close.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool _nativeClose()

        public:
        /*
         * Constructs a Transaction and stores _active.
         *
         * Takes no parameters.
         *
         * Returns the constructed Transaction.
         */
        Transaction() {
            _active = false
        }

        /*
         * Reports whether active for this Transaction.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool isActive() {
            if (!_nativeExists()) {
                return(false)
            }
            _active = _nativeActive()
            if (!_active) {
                _nativeClose()
            }
            return(_active)
        }

        /*
         * Handles commit for this Transaction.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool commit() {
            if (!isActive()) {
                return(false)
            }
            bool committed = _nativeCommit()
            if (committed) {
                _active = false
                _nativeClose()
            }
            return(committed)
        }

        /*
         * Handles rollback for this Transaction.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool rollback() {
            if (!isActive()) {
                return(false)
            }
            bool rolledBack = _nativeRollback()
            if (rolledBack) {
                _active = false
                _nativeClose()
            }
            return(rolledBack)
        }

        /*
         * Closes the Transaction state.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool close() {
            bool closed = _nativeClose()
            _active = false
            return(closed)
        }

        /*
         * Destroys this object and runs the cleanup owned by the instance.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        destroy {
            close()
        }

    }

    handle Connection._nativeOpen(String path) from "cwhip_sqlite_open"
    bool Connection._nativeClose(handle connection) from "cwhip_sqlite_close"
    void Connection._nativeReleaseConnection(handle connection) from "cwhip_sqlite_release_connection"
    String Connection._nativeConnectionError(handle connection) from "cwhip_sqlite_connection_error"
    bool Connection._nativeExecute(handle connection, String sql) from "cwhip_sqlite_execute"
    bool Connection._nativePrepare(
            handle connection,
            Statement target,
            String sql) from "cwhip_sqlite_prepare"
    bool Connection._nativeBusyTimeout(handle connection, int64 milliseconds) from "cwhip_sqlite_busy_timeout"
    bool Connection._nativeBeginTransaction(
            handle connection,
            Transaction target) from "cwhip_sqlite_begin_transaction"

    bool Statement._nativeExists() from "cwhip_sqlite_statement_exists"
    bool Statement._nativeFinalize() from "cwhip_sqlite_finalize"
    int64 Statement._nativeStep() from "cwhip_sqlite_step"
    String Statement._nativeStatementError() from "cwhip_sqlite_statement_error"
    bool Statement._nativeBindNull(int64 index) from "cwhip_sqlite_bind_null"
    bool Statement._nativeBindInteger(int64 index, int64 value) from "cwhip_sqlite_bind_integer"
    bool Statement._nativeBindReal(int64 index, fp64 value) from "cwhip_sqlite_bind_real"
    bool Statement._nativeBindText(int64 index, String value) from "cwhip_sqlite_bind_text"
    bool Statement._nativeBindBlob(int64 index, buffer value) from "cwhip_sqlite_bind_blob"
    int64 Statement._nativeColumnType(int64 index) from "cwhip_sqlite_column_type"
    int64 Statement._nativeColumnInteger(int64 index) from "cwhip_sqlite_column_integer"
    fp64 Statement._nativeColumnReal(int64 index) from "cwhip_sqlite_column_real"
    String Statement._nativeColumnText(int64 index) from "cwhip_sqlite_column_text"
    buffer Statement._nativeColumnBlob(int64 index) from "cwhip_sqlite_column_blob"

    bool Transaction._nativeExists() from "cwhip_sqlite_transaction_exists"
    bool Transaction._nativeActive() from "cwhip_sqlite_transaction_active"
    bool Transaction._nativeCommit() from "cwhip_sqlite_transaction_commit"
    bool Transaction._nativeRollback() from "cwhip_sqlite_transaction_rollback"
    bool Transaction._nativeClose() from "cwhip_sqlite_transaction_close"
}
