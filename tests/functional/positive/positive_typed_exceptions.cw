# Exercises typed subclass matching, mismatch propagation, runtime errors, and rethrow.
class DomainError : Exception {
  public:
  int64 code
  DomainError(strg text, int64 value) {
    super Exception(text)
    code = value
  }
}
class SpecificError : DomainError {
  public:
  SpecificError(strg text, int64 value) {
    super DomainError(text, value)
  }
}
class OtherError : Exception {
  public:
  OtherError(strg text) {
    super Exception(text)
  }
}
namespace errors {
  class QualifiedError : Exception {
    public:
    QualifiedError(strg text) {
      super Exception(text)
    }
  }
}
class ExceptionProbe {
  public:
  int64 same(Exception left, Exception right)
}
int64 ExceptionProbe.same(Exception left, Exception right) from "cwhip_method_demo_exception_identity"

start {
  try {
    raise(errors.QualifiedError("qualified clause matched"))
  } except(OtherError) {
    print("incorrect qualified first match")
  } except(errors.QualifiedError) as caught {
    print(caught.message)
  } except() {
    print("incorrect qualified fallback")
  }

  try {
    raise(SpecificError("ordered clause matched", 3))
  } except(OtherError) {
    print("incorrect first typed match")
  } except(SpecificError) as caught {
    print(caught.message)
  } except(DomainError) {
    print("incorrect base clause match")
  } except() {
    print("incorrect catch-all match")
  } finally {
    print("finally after matched clause")
  }

  try {
    raise(OtherError("later typed clause matched"))
  } except(DomainError) {
    print("incorrect earlier typed match")
  } except(OtherError) as caught {
    print(caught.message)
  } except() {
    print("incorrect typed fallback")
  }

  try {
    raise(Exception("catch-all matched"))
  } except(DomainError) {
    print("incorrect catch-all type match")
  } except() as message {
    print(message)
  }

  Exception original = null
  ExceptionProbe probe = ExceptionProbe()
  try {
    try {
      raise(SpecificError("rethrow preserved", 7))
    } except(DomainError) as caught {
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
  } except(SpecificError) as caught {
    print(caught.message)
    print(probe.same(original, caught))
  }

  try {
    int64 result = 1 / 0
  } except(DomainError) {
    print("incorrect runtime exception match")
  } except(Exception) as caught {
    print(caught.message)
  }

  ExceptionProbe missingProbe = null
  try {
    missingProbe.same(original, original)
  } except(Exception) {
    print("null caught as Exception")
  }

  list empty = []
  try {
    int64 missing = empty[0]
  } except(Exception) {
    print("bounds caught as Exception")
  }
}
