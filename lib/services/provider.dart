import 'package:flutter/material.dart';


class UserProvider extends ChangeNotifier {
late String _userId ="";

  String get userId => _userId;

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }
}

class DestinationProvider extends ChangeNotifier {
late String _destination ="";

  String get destination => _destination;

  void setDestination(String destination) {
   _destination = destination;
    notifyListeners();
  }
}