import 'package:flutter/material.dart';

import '../screens/list_contacts_screen.dart';
import '../screens/add_contact_screen.dart';

import '../widgets/search_contacts_form.dart';

import '../models/contact.dart';
import '../models/user.dart';

class SearchContactScreen extends StatelessWidget {
  final List<Contact> oldContacts;
  final User username;

  SearchContactScreen({this.oldContacts, this.username});

  @override
  Widget build(BuildContext context) {
    _handleListContacts() {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ListContactsScreen(
            oldContacts: this.oldContacts,
            username: this.username,
          ),
        ),
        (route) => false,
      );
    }

    _handleAddContact() {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => AddContactScreen(
              oldContacts: this.oldContacts, username: this.username),
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
                title: Text('Adicionar contato'),
                leading: Icon(Icons.person_add),
                onTap: _handleAddContact,
              ),
              ListTile(
                title: Text('Listar contatos'),
                leading: Icon(Icons.contacts),
                onTap: _handleListContacts,
              )
            ],
          ),
        ),
        margin: EdgeInsets.only(top: 85, right: 200),
      ),
      appBar: AppBar(
        title: Text("Procurar contatos"),
      ),
      body: SearchContactsForm(
        username: this.username.username,
      ),
    );
  }
}
