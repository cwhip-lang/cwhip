class Box : Exception {
  public:
  Box() {
    super Exception("box")
  }
}
start {
  Box error = Box()
  raise(error)
}
