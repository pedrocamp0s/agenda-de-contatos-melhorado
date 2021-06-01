import 'package:flutter/material.dart';

import '../widgets/update_contact_form.dart';

import '../models/contact.dart';

class UpdateContactScreen extends StatelessWidget {
  final Contact contact;

  UpdateContactScreen({this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adicionar contato"),
      ),
      body: UpdateContactForm(
        contact: this.contact,
      ),
    );
  }
}
