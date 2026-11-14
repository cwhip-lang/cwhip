# Constructor failures include the constructor and its Cwhip caller.
class Maker {
  public:
  Maker() {
    raise(Exception("constructor trace sentinel"))
  }
}
start {
  print("begin")
  Maker maker = Maker()
}
