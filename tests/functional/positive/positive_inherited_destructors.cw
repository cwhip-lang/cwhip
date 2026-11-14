# Exercises inherited and overridden destruction across single, multiple, and diamond inheritance, including failures.
class Primary {
  public:
  int64 primaryCode
  destroy {
    print(primaryCode)
  }
}

class Secondary {
  public:
  int64 secondaryCode
  destroy {
    print(secondaryCode)
  }
}

class Single : Primary {
  public:
  int64 ownCode
  Single(int64 code) {
    super Primary()
    primaryCode = code
    ownCode = code + 1
  }
  destroy {
    print(ownCode)
  }
}

class Multiple : Primary, Secondary {
  public:
  int64 ownCode
  Multiple(int64 code) {
    super Primary()
    primaryCode = code
    secondaryCode = code + 1
    ownCode = code + 2
  }
  destroy {
    print(ownCode)
  }
}

class InheritedOnly : Primary, Secondary {
  public:
  InheritedOnly(int64 code) {
    super Primary()
    primaryCode = code
    secondaryCode = code + 1
  }
}

class Maker {
  public:
  void makeUnreachable() {
    Multiple temporary = Multiple(1)
  }
}

class ThrowingBase {
  public:
  destroy {
    print("base after derived error")
    raise(Exception("base destructor failure"))
  }
}

class ThrowingDerived : ThrowingBase {
  public:
  ThrowingDerived() {
    super ThrowingBase()
  }
  destroy {
    raise(Exception("derived destructor failure"))
  }
}

class Root {
  public:
  destroy {
    print("root subobject")
  }
}

class Left : Root {
}

class Right : Root {
}

class Diamond : Left, Right {
  public:
  Diamond() {
    super Left()
  }
  destroy {
    print("diamond")
  }
}

start {
  Single single = Single(10)
  single.destroy()
  Primary baseView = Single(30)
  baseView.destroy()

  Maker maker = Maker()
  maker.makeUnreachable()
  inline { cwhip_gc_collect(); }
  Multiple explicit = Multiple(4)
  explicit.destroy()
  Multiple trigger = Multiple(20)

  ThrowingDerived throwing = ThrowingDerived()
  try {
    throwing.destroy()
  } except() as failure {
    print(failure)
  }
  try {
    throwing.destroy()
  } except() as repeated {
    print("caught repeated destruction")
  }

  Diamond diamond = Diamond()
  diamond.destroy()

  InheritedOnly inheritedOnly = InheritedOnly(50)
  inheritedOnly.destroy()
}
