namespace SQL {
    class Connection {
        public:
        bool isOpen() {
            raise(Exception("SQL connection backend does not implement isOpen"))
        }

        String error() {
            raise(Exception("SQL connection backend does not implement error"))
        }

        bool execute(String sql) {
            raise(Exception("SQL connection backend does not implement execute"))
        }

        Statement prepare(String sql) {
            raise(Exception("SQL connection backend does not implement prepare"))
        }

        Transaction beginTransaction() {
            raise(Exception("SQL connection backend does not implement beginTransaction"))
        }

        bool close() {
            raise(Exception("SQL connection backend does not implement close"))
        }
    }

    class Statement {
        public:
        String error() {
            raise(Exception("SQL statement backend does not implement error"))
        }

        bool bind(int64 oneBasedIndex, Value value) {
            raise(Exception("SQL statement backend does not implement bind"))
        }

        bool step() {
            raise(Exception("SQL statement backend does not implement step"))
        }

        bool hasRow() {
            raise(Exception("SQL statement backend does not implement hasRow"))
        }

        bool isDone() {
            raise(Exception("SQL statement backend does not implement isDone"))
        }

        bool failed() {
            raise(Exception("SQL statement backend does not implement failed"))
        }

        Value value(int64 zeroBasedColumnIndex) {
            raise(Exception("SQL statement backend does not implement value"))
        }

        bool close() {
            raise(Exception("SQL statement backend does not implement close"))
        }
    }

    class Transaction {
        public:
        bool isActive() {
            raise(Exception("SQL transaction backend does not implement isActive"))
        }

        bool commit() {
            raise(Exception("SQL transaction backend does not implement commit"))
        }

        bool rollback() {
            raise(Exception("SQL transaction backend does not implement rollback"))
        }

        bool close() {
            raise(Exception("SQL transaction backend does not implement close"))
        }
    }

    class Value {
        private:
        int64 _kind
        int64 _integer
        fp64 _real
        String _text
        buffer _blob

        public:
        Value() {
            _kind = 0
            _integer = 0
            _real = 0.0
            _text = null
            _blob = null
        }

        Value(int64 value) {
            _kind = 1
            _integer = value
            _real = 0.0
            _text = null
            _blob = null
        }

        Value(fp64 value) {
            _kind = 2
            _integer = 0
            _real = value
            _text = null
            _blob = null
        }

        Value(String value) {
            if (value == null) { raise(Exception("SQL text values cannot be null; use Value() for SQL NULL")) }
            _kind = 3
            _integer = 0
            _real = 0.0
            _text = value
            _blob = null
        }

        Value(buffer value) {
            if (value == null) { raise(Exception("SQL blob values cannot be null; use Value() for SQL NULL")) }
            _kind = 4
            _integer = 0
            _real = 0.0
            _text = null
            _blob = value
        }

        int64 kind() {
            return(_kind)
        }

        bool isNull() {
            return(_kind == 0)
        }

        int64 asInteger() {
            if (_kind != 1) { raise(Exception("SQL value is not an integer")) }
            return(_integer)
        }

        fp64 asReal() {
            if (_kind != 2) { raise(Exception("SQL value is not a real")) }
            return(_real)
        }

        String asText() {
            if (_kind != 3) { raise(Exception("SQL value is not text")) }
            return(_text)
        }

        buffer asBlob() {
            if (_kind != 4) { raise(Exception("SQL value is not a blob")) }
            return(_blob)
        }
    }
}
