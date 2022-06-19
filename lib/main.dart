import 'package:calorie_budget/authentication/login.dart';
import 'package:calorie_budget/firebase_options.dart';
import 'package:calorie_budget/home.dart';
import 'package:calorie_budget/loading.dart';
import 'package:calorie_budget/models/profile.dart';
import 'package:calorie_budget/profile_page.dart';
import 'package:calorie_budget/server_error.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CalabungaApp());
}

class CalabungaApp extends StatefulWidget {
  const CalabungaApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  State<CalabungaApp> createState() => _CalabungaAppState();
}

class _CalabungaAppState extends State<CalabungaApp> {
  bool _error = false;
  bool _loading = true;
  Stream<Profile?>? _profileStream;
  String? _uid;

  Future<bool> initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      return true;
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    initializeFlutterFire().then((initialized) {
      if (initialized) {
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
          setState(() {
            if (user != null) _profileStream = Profile.getStream(user.uid);
            _uid = user?.uid;
            _loading = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: _error
          ? const ServerErrorScreen()
          : _loading
              ? const LoadingPage()
              : StreamBuilder<Profile?>(
                  stream: _profileStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const ServerErrorScreen();
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loading();
                    }
                    if (_uid == null) return const Login();
                    if (!snapshot.hasData) {
                      return ProfilePage(
                        uid: _uid!,
                      );
                    }
                    return Home(uid: _uid!);
                  }),
      routes: {
        'login': (context) => const Login(),
      },
    );
  }
}
