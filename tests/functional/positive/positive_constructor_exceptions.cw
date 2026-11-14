# Exercises exceptions raised from direct constructors, typed handlers, base constructors, and failed partial objects.
class OtherException : Exception {
  public:
  OtherException(strg msg) {
    super Exception(msg)
  }
}
class TypedFailure : Exception {
  public:
  TypedFailure(strg msg) {
    super Exception(msg)
  }
}
class GenericFailure {
  public:
  GenericFailure() {
    raise(Exception("generic constructor failure"))
  }
  destroy {
    print("invalid generic partial finalizer")
  }
}
class TypedThrower {
  public:
  TypedThrower(int64 value) {
    raise(TypedFailure("typed constructor failure"))
  }
  destroy {
    print("invalid typed partial finalizer")
  }
}
class FailingBase {
  public:
  FailingBase() {
    raise(OtherException("base constructor failure"))
  }
  destroy {
    print("invalid base partial finalizer")
  }
}
class DerivedFromFailingBase : FailingBase {
  public:
  DerivedFromFailingBase() {
    super FailingBase()
    print("invalid derived constructor continuation")
  }
  destroy {
    print("invalid derived partial finalizer")
  }
}
start {
  print("before constructor exceptions")

  try {
    GenericFailure direct()
    print("invalid direct continuation")
  } except(OtherException) {
    print("invalid typed handler for generic failure")
  } except() {
    print("caught direct constructor raise")
  }

  try {
    TypedThrower typed(1)
  } except(OtherException) {
    print("invalid other handler")
  } except(TypedFailure) as caught {
    print(caught.message)
  } except() {
    print("invalid typed fallback")
  }

  try {
    DerivedFromFailingBase derived()
  } except(OtherException) as caught {
    print(caught.message)
  } except() {
    print("invalid base fallback")
  }

  try {
    GenericFailure assigned = GenericFailure()
  } except() as message {
    print(message)
  }

  print("after constructor exceptions")
}
