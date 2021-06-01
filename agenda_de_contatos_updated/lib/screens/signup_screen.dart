import 'package:flutter/material.dart';

import '../widgets/signup_form.dart';

import '../models/user.dart';

class SignUpScreen extends StatelessWidget {
  final List<User> users;

  SignUpScreen({this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
      ),
      body: SignUpForm(
        users: this.users,
      ),
    );
  }
}
