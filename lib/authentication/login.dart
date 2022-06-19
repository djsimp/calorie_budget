import 'package:calorie_budget/authentication/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController verifyPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';
  bool _register = false;

  void login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          setState(() => _errorMessage = 'No user found for that email.');
        } else if (e.code == 'wrong-password') {
          setState(
              () => _errorMessage = 'Wrong password provided for that user.');
        }
      }
    }
  }

  void register() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          setState(() => _errorMessage = 'The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          setState(() =>
              _errorMessage = 'An account already exists for that email.');
        }
      } catch (e) {
        setState(() => _errorMessage = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      autocorrect: false,
                      validator: emailValidator,
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      autocorrect: false,
                      obscureText: true,
                      validator: passwordValidator,
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                    ),
                  ),
                  if (_register)
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        autocorrect: false,
                        validator: (value) {
                          return verifyPasswordValidator(
                            value,
                            passwordController.text,
                          );
                        },
                        obscureText: true,
                        controller: verifyPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Verify Password',
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(_errorMessage),
                  ),
                  ElevatedButton(
                    onPressed: _register ? register : login,
                    child: Text(_register ? 'Register' : 'Login'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(_register
                          ? 'Already have an account?'
                          : "Don't have an account?"),
                      TextButton(
                        child: Text(_register ? 'Login' : 'Register'),
                        onPressed: () => setState(() => _register = !_register),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
