import 'package:flutter/material.dart';

class ServerErrorScreen extends StatelessWidget {
  const ServerErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ServerError());
  }
}

class ServerError extends StatelessWidget {
  const ServerError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.7,
        child: Text("Something went wrong while connecting to the server."),
      ),
    );
  }
}
