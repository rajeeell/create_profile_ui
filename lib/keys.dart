import 'package:flutter/material.dart';

class Keys {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey();

  static snackBar(String message) {
    Keys.scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
