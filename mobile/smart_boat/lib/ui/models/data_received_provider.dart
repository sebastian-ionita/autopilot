import 'package:flutter/foundation.dart';

class DataReceived with ChangeNotifier {
  bool _dataReceived = false;

  bool get dataReceived => _dataReceived;

  void setFlag() {
    _dataReceived = !_dataReceived;
    notifyListeners();
  }
}
