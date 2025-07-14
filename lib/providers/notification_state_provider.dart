import 'package:flutter/material.dart';

class NotificationStateProvider with ChangeNotifier {
  int _notificationCount = 0;
  int get notificationCount => _notificationCount;

  void setNotificationCount(int value) {
    _notificationCount = value;
    notifyListeners();
  }

  void incrementNotificationCount() {
    _notificationCount++;
    notifyListeners();
  }

  Future<void> fetchNotificationCount(count) async {
    _notificationCount = count;
    notifyListeners();
  }
}
