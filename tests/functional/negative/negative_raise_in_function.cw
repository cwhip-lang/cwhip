class Worker {
  public:
  void fail() {
    raise()
  }
}
start {
  Worker worker = Worker()
  try {
    raise(Exception("original"))
  } except() {
    worker.fail()
  }
}
