# A caught exception must not print an uncaught stack trace.
class Worker {
  public:
  void inner(Worker self) {
    raise(Exception("caught sentinel"))
  }
  void outer(Worker self) {
    self.inner(self)
  }
}
start {
  Worker worker = Worker()
  try {
    worker.outer(worker)
  } except() {
    print("caught")
  }
}
