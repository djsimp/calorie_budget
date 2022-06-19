import 'package:flutter/material.dart';

mixin SnackBarMixin<T extends StatefulWidget> on State<T> {
  void showSnackBarMessage(String message, {Color? backgroundColor}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
