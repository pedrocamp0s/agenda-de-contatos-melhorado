import 'package:flutter/material.dart';

import '../screens/list_contacts_screen.dart';
import '../screens/search_contact_screen.dart';
import '../widgets/add_contact_form.dart';

import '../models/contact.dart';
import '../models/user.dart';

class AddContactScreen extends StatelessWidget {
  final List<Contact> oldContacts;
  final User username;

  AddContactScreen({this.oldContacts, this.username});

  @override
  Widget build(BuildContext context) {
    _handleListContacts() {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ListContactsScreen(
              oldContacts: this.oldContacts, username: this.username),
        ),
        (route) => false,
      );
    }

    _handleSearchContacts() {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => SearchContactScreen(
            oldContacts: this.oldContacts,
            username: this.username,
          ),
        ),
        (route) => false,
      );
    }

    return Scaffold(
      drawer: Container(
        child: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: Text('Listar contatos'),
                leading: Icon(Icons.contacts),
                onTap: _handleListContacts,
              ),
              ListTile(
                title: Text('Procurar contatos'),
                leading: Icon(Icons.person_search),
                onTap: _handleSearchContacts,
              )
            ],
          ),
        ),
        margin: EdgeInsets.only(top: 85, right: 200),
      ),
      appBar: AppBar(
        title: Text("Adicionar contato"),
      ),
      body: AddContactForm(
        oldContacts: this.oldContacts,
        username: this.username,
      ),
    );
  }
}
