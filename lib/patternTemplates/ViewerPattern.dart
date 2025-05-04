abstract class Viewer {
  void notice(String? data);
}

abstract class Teller {
  List<Viewer> subscribersList = [];

  void subscribe(Viewer v) => subscribersList.add(v);

  void unsubscribe(Viewer v) => subscribersList.remove(v);

  void translateData(String? message);
}