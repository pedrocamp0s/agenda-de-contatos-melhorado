import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';

import '../screens/signup_screen.dart';
import '../screens/add_contact_screen.dart';

import '../models/user.dart';
import '../models/contact.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _controllerForUsername = TextEditingController();
  final _controllerForPassword = TextEditingController();
  final db = FirebaseDatabase.instance.reference().child("users");
  final dbOfContacts = FirebaseDatabase.instance.reference().child("contacts");

  bool loading = false;

  String _validateUsername(value) {
    String validationResult;

    if (value == null || value.isEmpty) {
      validationResult = 'Digite um nome de usuário para continuar';
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

  Future<List<User>> getUsers() async {
    DataSnapshot data = await db.once();
    if (data.value == null) {
      return [];
    }
    Map<String, dynamic> dynamicMaps =
        new Map<String, dynamic>.from(data.value);
    List<dynamic> maps = new List<dynamic>.from(dynamicMaps.values);

    return List.generate(maps.length, (i) {
      return User(
        username: maps[i]['username'],
        password: maps[i]['password'],
        email: maps[i]['email'],
      );
    });
  }

  void showErrorMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<List<Contact>> _getContacts(String username) async {
    DataSnapshot data =
        await dbOfContacts.orderByChild("owner").equalTo(username).once();
    if (data.value == null) {
      return [];
    }
    Map<String, dynamic> dynamicMaps =
        new Map<String, dynamic>.from(data.value);
    List<dynamic> maps = new List<dynamic>.from(dynamicMaps.keys);

    List<Contact> newContacts = List.generate(maps.length, (i) {
      return Contact(
          key: maps[i],
          name: dynamicMaps[maps[i]]['name'],
          email: dynamicMaps[maps[i]]['email'],
          publicPlace: dynamicMaps[maps[i]]['publicPlace'],
          state: dynamicMaps[maps[i]]['state'],
          city: dynamicMaps[maps[i]]['city'],
          zipCode: dynamicMaps[maps[i]]['zipCode'],
          district: dynamicMaps[maps[i]]['district'],
          houseNumber: dynamicMaps[maps[i]]['houseNumber'],
          imgPath: dynamicMaps[maps[i]]['imgPath'],
          complement: dynamicMaps[maps[i]]['complement'],
          phone: dynamicMaps[maps[i]]['phone'],
          owner: dynamicMaps[maps[i]]['owner']);
    });
    newContacts.sort((a, b) => a.name.compareTo(b.name));

    return newContacts;
  }

  @override
  Widget build(BuildContext context) {
    void _makeLogin() async {
      if (_formKey.currentState.validate()) {
        setState(() {
          this.loading = true;
        });

        List<User> users = await getUsers();

        bool userExists = false;

        for (var user in users) {
          if (this._controllerForUsername.text == user.username) {
            userExists = true;
            if (this._controllerForPassword.text == user.password) {
              List<Contact> oldContacts = await _getContacts(user.username);
              setState(() {
                this.loading = false;
              });
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddContactScreen(
                            oldContacts: oldContacts,
                            username: user,
                          )),
                  (route) => false);
            } else {
              showErrorMessage('A senha inserida está errada!', context);
            }
          }
        }

        if (!userExists) {
          showErrorMessage('O usuário inserido não existe!', context);
        }

        if (this.loading) {
          setState(() {
            this.loading = false;
          });
        }
      }
    }

    void _doSignup() async {
      setState(() {
        this.loading = true;
      });

      List<User> users = await getUsers();

      setState(() {
        this.loading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpScreen(
            users: users,
          ),
        ),
      );
    }

    return Form(
      key: this._formKey,
      child: Column(
        children: [
          Container(
            child: TextFormField(
              controller: this._controllerForUsername,
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
          Row(
            children: [
              Container(
                child: ElevatedButton(
                  onPressed: _makeLogin,
                  child: Text('Entrar'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                ),
                margin: EdgeInsets.only(right: 20),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: _doSignup,
                  child: Text('Inscrever-se'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  ),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          this.loading
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(
                      value: null,
                    ),
                  ),
                  margin: EdgeInsets.only(top: 50),
                )
              : Container(),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
