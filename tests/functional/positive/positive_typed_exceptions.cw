/*
 * tests/functional/positive/positive_typed_exceptions.cw
 *
 * Exercises typed subclass matching, mismatch propagation, runtime errors, and
 * rethrow.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * DomainError is a class derived from Exception, used as a fixture by this
 * test.
 *
 * Its methods include constructor.
 */
class DomainError : Exception {
    public:
    int64 code

    /*
     * Constructs a DomainError and stores code.
     *
     * Parameters:
     *   text — strg text.
     *   value — int64 value.
     *
     * Returns the constructed DomainError.
     */
    DomainError(strg text, int64 value) {
        super Exception(text)
        code = value
    }
}

/*
 * SpecificError is a class derived from DomainError, used as a fixture by this
 * test.
 *
 * Its methods include constructor.
 */
class SpecificError : DomainError {
    public:
    /*
     * Constructs a SpecificError.
     *
     * Parameters:
     *   text — strg text.
     *   value — int64 value.
     *
     * Returns the constructed SpecificError.
     */
    SpecificError(strg text, int64 value) {
        super DomainError(text, value)
    }
}

/*
 * OtherError is a class derived from Exception, used as a fixture by this
 * test.
 *
 * Its methods include constructor.
 */
class OtherError : Exception {
    public:
    /*
     * Constructs a OtherError.
     *
     * Parameters:
     *   text — strg text.
     *
     * Returns the constructed OtherError.
     */
    OtherError(strg text) {
        super Exception(text)
    }
}
namespace errors {

    /*
     * QualifiedError is a class derived from Exception, used as a fixture by
     * this test.
     *
     * Its methods include constructor.
     */
    class QualifiedError : Exception {
        public:
        /*
         * Constructs a QualifiedError.
         *
         * Parameters:
         *   text — strg text.
         *
         * Returns the constructed QualifiedError.
         */
        QualifiedError(strg text) {
            super Exception(text)
        }
    }
}

/*
 * ExceptionProbe is a class, used as a fixture by this test.
 *
 * Its methods include same.
 */
class ExceptionProbe {
    public:
    /*
     * Handles same for this ExceptionProbe by calling the native function
     * cwhip_method_demo_exception_identity.
     *
     * Parameters:
     *   left — Exception left.
     *   right — Exception right.
     *
     * Returns int64.
     */
    int64 same(Exception left, Exception right)
}
int64 ExceptionProbe.same(Exception left, Exception right) from "cwhip_method_demo_exception_identity"

start {
    try {
        raise(errors.QualifiedError("qualified clause matched"))
    }
    except(OtherError) {
        print("incorrect qualified first match")
    }
    except(errors.QualifiedError) as caught {
        print(caught.message)
    }
    except() {
        print("incorrect qualified fallback")
    }

    try {
        raise(SpecificError("ordered clause matched", 3))
    }
    except(OtherError) {
        print("incorrect first typed match")
    }
    except(SpecificError) as caught {
        print(caught.message)
    }
    except(DomainError) {
        print("incorrect base clause match")
    }
    except() {
        print("incorrect catch-all match")
    }
    finally {
        print("finally after matched clause")
    }

    try {
        raise(OtherError("later typed clause matched"))
    }
    except(DomainError) {
        print("incorrect earlier typed match")
    }
    except(OtherError) as caught {
        print(caught.message)
    }
    except() {
        print("incorrect typed fallback")
    }

    try {
        raise(Exception("catch-all matched"))
    }
    except(DomainError) {
        print("incorrect catch-all type match")
    }
    except() as message {
        print(message)
    }

    Exception original = null
    ExceptionProbe probe = ExceptionProbe()
    try {
        try {
            raise(SpecificError("rethrow preserved", 7))
        }
        except(DomainError) as caught {
            int64 churn = 0
            while (churn < 8) {
                Exception discarded = Exception("temporary")
                churn = churn + 1
            }
            print(caught.message)
            original = caught
            {
                raise()
            }
        }
    }
    except(SpecificError) as caught {
        print(caught.message)
        print(probe.same(original, caught))
    }

    try {
        int64 result = 1 / 0
    }
    except(DomainError) {
        print("incorrect runtime exception match")
    }
    except(Exception) as caught {
        print(caught.message)
    }

    ExceptionProbe missingProbe = null
    try {
        missingProbe.same(original, original)
    }
    except(Exception) {
        print("null caught as Exception")
    }

    list empty = []
    try {
        int64 missing = empty[0]
    }
    except(Exception) {
        print("bounds caught as Exception")
    }
}
