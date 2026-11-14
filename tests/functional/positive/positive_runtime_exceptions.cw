# Exercises exceptions from methods, constructors, destructors, handlers, finally blocks, null access, and division.
class Box {
  public:
  destroy {
  }
  int64 read() {
    return(42)
  }
}
class Worker {
  public:
  int64 fail() {
    Box local = Box()
    raise(Exception("from method"))
    return(0)
  }
}
class ThrowingBox {
  public:
  destroy {
    raise(Exception("from destructor"))
  }
  int64 read() {
    return(9)
  }
}
class Partial {
  public:
  Partial() {
    raise(Exception("constructor failed"))
  }
  destroy {
    print("invalid partial finalizer")
  }
}
class Builder {
  public:
  void build() {
    Partial partial = Partial()
  }
}
start {
  try {
    raise(Exception("requested"))
  } except() {
    print("caught raise")
  } finally {
    print("finally after exception")
  }

  try {
    print(1)
  } finally {
    print("finally after success")
  }

  Worker worker = Worker()
  try {
    worker.fail()
  } except() {
    print("caught method raise")
  }

  Builder builder = Builder()
  try {
    builder.build()
  } except() {
    print("caught constructor raise")
  }
  Box afterFailure = Box()

  ThrowingBox doomed = ThrowingBox()
  try {
    doomed.destroy()
  } except() {
    print("caught destructor raise")
  }
  try {
    print(doomed.read())
  } except() {
    print("caught destroyed after destructor raise")
  }

  try {
    try {
      raise(Exception("original"))
    } except() {
      raise(Exception("from handler"))
    } finally {
      print("finally after handler error")
    }
  } except() {
    print("caught handler raise")
  }

  try {
    try {
      print(2)
    } finally {
      raise(Exception("from finally"))
    }
  } except() {
    print("caught finally raise")
  }

  Box box = Box()
  box.destroy()
  try {
    box.destroy()
  } except() {
    print("caught repeated destruction")
  }
  try {
    print(box.read())
  } except() {
    print("caught destroyed object")
  }

  Box missing = null
  try {
    print(missing.read())
  } except() {
    print("caught null reference")
  }

  try {
    print(42 / 0)
  } except() {
    print("caught division by zero")
  }

  try {
    if (true) {
      raise(Exception("first branch"))
    } else {
      raise(Exception("second branch"))
    }
  } except() {
    print("caught conditional raise")
  }
}
