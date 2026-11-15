/*
 * stdlib/sql/0.1.0/sql.cw — sql package implementation.
 *
 * Created: 2026-10-06
 * Author: chuck
 *
 * Changelog:
 *   2026-10-06  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace SQL {

    /*
     * Connection is a class in this standard-library package.
     *
     * Its methods include isOpen, error, execute, prepare, beginTransaction,
     * close.
     */
    class Connection {
        public:
        /*
         * Reports whether open for this Connection. Raises Exception when the
         * call is not valid (SQL connection backend does not implement
         * isOpen).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool isOpen() {
            raise(Exception("SQL connection backend does not implement isOpen"))
        }

        /*
         * Handles error for this Connection. Raises Exception when the call is
         * not valid (SQL connection backend does not implement error).
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String error() {
            raise(Exception("SQL connection backend does not implement error"))
        }

        /*
         * Handles execute for this Connection. Raises Exception when the call
         * is not valid (SQL connection backend does not implement execute).
         *
         * Parameters:
         *   sql — String sql.
         *
         * Returns bool.
         */
        bool execute(String sql) {
            raise(
                    Exception(
                    "SQL connection backend does not implement execute"))
        }

        /*
         * Handles prepare for this Connection. Raises Exception when the call
         * is not valid (SQL connection backend does not implement prepare).
         *
         * Parameters:
         *   sql — String sql.
         *
         * Returns Statement.
         */
        Statement prepare(String sql) {
            raise(
                    Exception(
                    "SQL connection backend does not implement prepare"))
        }

        /*
         * Handles begin transaction for this Connection. Raises Exception when
         * the call is not valid (SQL connection backend does not implement
         * beginTransaction).
         *
         * Takes no parameters.
         *
         * Returns Transaction.
         */
        Transaction beginTransaction() {
            raise(Exception(
                    "SQL connection backend does not implement beginTransaction"))
        }

        /*
         * Closes the Connection state. Raises Exception when the call is not
         * valid (SQL connection backend does not implement close).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool close() {
            raise(Exception("SQL connection backend does not implement close"))
        }
    }

    /*
     * Statement is a class in this standard-library package.
     *
     * Its methods include error, bind, step, hasRow, isDone, failed, and 2
     * more.
     */
    class Statement {
        public:
        /*
         * Handles error for this Statement. Raises Exception when the call is
         * not valid (SQL statement backend does not implement error).
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String error() {
            raise(Exception("SQL statement backend does not implement error"))
        }

        /*
         * Binds the Statement state. Raises Exception when the call is not
         * valid (SQL statement backend does not implement bind).
         *
         * Parameters:
         *   oneBasedIndex — int64 one based index.
         *   value — Value value.
         *
         * Returns bool.
         */
        bool bind(int64 oneBasedIndex, Value value) {
            raise(Exception("SQL statement backend does not implement bind"))
        }

        /*
         * Handles step for this Statement. Raises Exception when the call is
         * not valid (SQL statement backend does not implement step).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool step() {
            raise(Exception("SQL statement backend does not implement step"))
        }

        /*
         * Reports whether this object has row for this Statement. Raises
         * Exception when the call is not valid (SQL statement backend does not
         * implement hasRow).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool hasRow() {
            raise(Exception("SQL statement backend does not implement hasRow"))
        }

        /*
         * Reports whether done for this Statement. Raises Exception when the
         * call is not valid (SQL statement backend does not implement isDone).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool isDone() {
            raise(Exception("SQL statement backend does not implement isDone"))
        }

        /*
         * Handles failed for this Statement. Raises Exception when the call is
         * not valid (SQL statement backend does not implement failed).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool failed() {
            raise(Exception("SQL statement backend does not implement failed"))
        }

        /*
         * Handles value for this Statement. Raises Exception when the call is
         * not valid (SQL statement backend does not implement value).
         *
         * Parameters:
         *   zeroBasedColumnIndex — int64 zero based column
         *     index.
         *
         * Returns Value.
         */
        Value value(int64 zeroBasedColumnIndex) {
            raise(Exception("SQL statement backend does not implement value"))
        }

        /*
         * Closes the Statement state. Raises Exception when the call is not
         * valid (SQL statement backend does not implement close).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool close() {
            raise(Exception("SQL statement backend does not implement close"))
        }
    }

    /*
     * Transaction is a class in this standard-library package.
     *
     * Its methods include isActive, commit, rollback, close.
     */
    class Transaction {
        public:
        /*
         * Reports whether active for this Transaction. Raises Exception when
         * the call is not valid (SQL transaction backend does not implement
         * isActive).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool isActive() {
            raise(Exception(
                    "SQL transaction backend does not implement isActive"))
        }

        /*
         * Handles commit for this Transaction. Raises Exception when the call
         * is not valid (SQL transaction backend does not implement commit).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool commit() {
            raise(
                    Exception(
                    "SQL transaction backend does not implement commit"))
        }

        /*
         * Handles rollback for this Transaction. Raises Exception when the
         * call is not valid (SQL transaction backend does not implement
         * rollback).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool rollback() {
            raise(Exception(
                    "SQL transaction backend does not implement rollback"))
        }

        /*
         * Closes the Transaction state. Raises Exception when the call is not
         * valid (SQL transaction backend does not implement close).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool close() {
            raise(Exception("SQL transaction backend does not implement close"))
        }
    }

    /*
     * Value is a class in this standard-library package.
     *
     * Its methods include constructor, kind, isNull, asInteger, asReal,
     * asText, and 1 more.
     */
    class Value {
        private:
        int64 _kind
        int64 _integer
        fp64 _real
        String _text
        buffer _blob

        public:
        /*
         * Constructs a Value and stores _kind, _integer, _real, _text.
         *
         * Takes no parameters.
         *
         * Returns the constructed Value.
         */
        Value() {
            _kind = 0
            _integer = 0
            _real = 0.0
            _text = null
            _blob = null
        }

        /*
         * Constructs a Value and stores _kind, _integer, _real, _text.
         *
         * Parameters:
         *   value — int64 value.
         *
         * Returns the constructed Value.
         */
        Value(int64 value) {
            _kind = 1
            _integer = value
            _real = 0.0
            _text = null
            _blob = null
        }

        /*
         * Constructs a Value and stores _kind, _integer, _real, _text.
         *
         * Parameters:
         *   value — fp64 value.
         *
         * Returns the constructed Value.
         */
        Value(fp64 value) {
            _kind = 2
            _integer = 0
            _real = value
            _text = null
            _blob = null
        }

        /*
         * Constructs a Value and stores value, _kind, _integer, _real.
         *
         * Parameters:
         *   value — String value.
         *
         * Returns the constructed Value.
         */
        Value(String value) {
            if (value == null) {
                raise(Exception(
                        "SQL text values cannot be null; use Value() for SQL NULL"))
            }
            _kind = 3
            _integer = 0
            _real = 0.0
            _text = value
            _blob = null
        }

        /*
         * Constructs a Value and stores value, _kind, _integer, _real.
         *
         * Parameters:
         *   value — buffer value.
         *
         * Returns the constructed Value.
         */
        Value(buffer value) {
            if (value == null) {
                raise(Exception(
                        "SQL blob values cannot be null; use Value() for SQL NULL"))
            }
            _kind = 4
            _integer = 0
            _real = 0.0
            _text = null
            _blob = value
        }

        /*
         * Returns the stored _kind.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 kind() {
            return(_kind)
        }

        /*
         * Returns _kind == 0.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool isNull() {
            return(_kind == 0)
        }

        /*
         * Handles as integer for this Value. Raises Exception when the call is
         * not valid (SQL value is not an integer).
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 asInteger() {
            if (_kind != 1) {
                raise(Exception("SQL value is not an integer"))
            }
            return(_integer)
        }

        /*
         * Handles as real for this Value. Raises Exception when the call is
         * not valid (SQL value is not a real).
         *
         * Takes no parameters.
         *
         * Returns fp64.
         */
        fp64 asReal() {
            if (_kind != 2) {
                raise(Exception("SQL value is not a real"))
            }
            return(_real)
        }

        /*
         * Handles as text for this Value. Raises Exception when the call is
         * not valid (SQL value is not text).
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String asText() {
            if (_kind != 3) {
                raise(Exception("SQL value is not text"))
            }
            return(_text)
        }

        /*
         * Handles as blob for this Value. Raises Exception when the call is
         * not valid (SQL value is not a blob).
         *
         * Takes no parameters.
         *
         * Returns buffer.
         */
        buffer asBlob() {
            if (_kind != 4) {
                raise(Exception("SQL value is not a blob"))
            }
            return(_blob)
        }
    }
}
