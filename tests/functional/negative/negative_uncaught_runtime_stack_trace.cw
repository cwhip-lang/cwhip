# Runtime failures in nested methods report the active Cwhip call frames.
class Worker {
  public:
  int64 inner(Worker self) {
    return(8 / 0)
  }
  int64 middle(Worker self) {
    return(self.inner(self))
  }
  int64 outer(Worker self) {
    return(self.middle(self))
  }
}
start {
  Worker worker = Worker()
  print("begin")
  print(worker.outer(worker))
}
