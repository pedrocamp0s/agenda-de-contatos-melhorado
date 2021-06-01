import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';

import '../models/user.dart';

class SignUpForm extends StatefulWidget {
  final List<User> users;

  SignUpForm({this.users});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _controllerForName = TextEditingController();
  final _controllerForPassword = TextEditingController();
  final _controllerForEmail = TextEditingController();
  final db = FirebaseDatabase.instance.reference().child("users");

  String _validateUsername(value) {
    String validationResult;

    if (value == null || value.isEmpty) {
      validationResult = 'Digite um nome de usuário para continuar';
    }

    bool usernameExists = false;

    for (var user in this.widget.users) {
      if (value == user.username) {
        usernameExists = true;
        break;
      }
    }

    if (usernameExists) {
      validationResult =
          'Já existe um usuário com esse username, insira outro por favor!';
    }

    return validationResult;
  }

  String _validatePassword(value) {
    String validationResult;

    if (value == null || value.isEmpty) {
      validationResult = 'Digite uma senha para continuar';
    }

    return validationResult;
  }

  String _validateEmail(value) {
    String validationResult;
    bool isValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);

    if (value == null || value.isEmpty) {
      validationResult = 'Digite um email para continuar';
    }

    if (!isValid) {
      validationResult = 'Insira um email válido. Exemplo: exemplo@teste.com';
    }

    bool emailExists = false;

    for (var user in this.widget.users) {
      if (value == user.email) {
        emailExists = true;
        break;
      }
    }

    if (emailExists) {
      validationResult =
          'Já existe um usuário com esse email, insira outro por favor!';
    }

    return validationResult;
  }

  void clearFields() {
    this._controllerForName.clear();
    this._controllerForPassword.clear();
    this._controllerForEmail.clear();
  }

  Future<void> insertUser(User user, BuildContext context) async {
    this.db.push().set({
      "username": user.username,
      "password": user.password,
      "email": user.email
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
        ),
      );
      this.clearFields();
    }).catchError((onError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(onError),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    void _completeSignup() async {
      if (_formKey.currentState.validate()) {
        await insertUser(
            new User(
                username: this._controllerForName.text,
                email: this._controllerForEmail.text,
                password: this._controllerForPassword.text),
            context);
        Navigator.pop(context);
      }
    }

    void _cancelSignup() {
      this.clearFields();
      Navigator.pop(context);
    }

    return Form(
      key: this._formKey,
      child: Column(
        children: [
          Container(
            child: TextFormField(
              controller: this._controllerForName,
              decoration: InputDecoration(
                labelText: 'Nome de usuário',
                errorMaxLines: 2,
              ),
              validator: this._validateUsername,
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForPassword,
              decoration: InputDecoration(
                labelText: 'Senha',
                errorMaxLines: 2,
              ),
              validator: this._validatePassword,
              obscureText: true,
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForEmail,
              decoration: InputDecoration(
                labelText: 'Email',
                errorMaxLines: 2,
              ),
              validator: this._validateEmail,
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Row(
            children: [
              Container(
                child: ElevatedButton(
                  onPressed: _completeSignup,
                  child: Text('Cadastrar'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                ),
                margin: EdgeInsets.only(right: 20),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: _cancelSignup,
                  child: Text('Cancelar'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
