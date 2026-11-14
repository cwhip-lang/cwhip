# Uncaught explicit exceptions retain Cwhip method frames from innermost to start.
class Worker {
  public:
  void inner(Worker self) {
    raise(Exception("trace sentinel"))
  }
  void outer(Worker self) {
    self.inner(self)
  }
}
start {
  Worker worker = Worker()
  print("begin")
  worker.outer(worker)
}
