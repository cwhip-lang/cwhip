# Checks named exception bindings, finally execution, saved exception text, and runtime errors exposed to handlers.
class Box {
  public:
  strg note
  int64 read() {
    return(1)
  }
}

start {
  Box saved = Box()
  try {
    raise(Exception("raised detail"))
  } except() as message {
    print(message)
  } finally {
    print("finally after bound exception")
  }

  try {
    raise(Exception("retained detail"))
  } except() as message {
    saved.note = message
  }
  print(saved.note)

  try {
    print(7 / 0)
  } except() as runtime {
    print(runtime)
  }

  Box missing = null
  try {
    print(missing.read())
  } except() as runtime {
    print(runtime)
  }

  try {
    try {
      raise(Exception("original detail"))
    } except() as original {
      raise(Exception("replacement detail"))
    }
  } except() as replacement {
    print(replacement)
  }
}
