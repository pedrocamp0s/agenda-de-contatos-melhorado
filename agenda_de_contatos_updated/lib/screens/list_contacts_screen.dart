import 'package:flutter/material.dart';
import 'dart:io';

import '../screens/add_contact_screen.dart';
import '../screens/search_contact_screen.dart';
import '../widgets/contact_details.dart';

import 'package:firebase_database/firebase_database.dart';

import '../models/contact.dart';
import '../models/user.dart';

class ListContactsScreen extends StatefulWidget {
  final List<Contact> oldContacts;
  final User username;

  ListContactsScreen({this.oldContacts, this.username});

  @override
  _ListContactsScreenState createState() => _ListContactsScreenState();
}

class _ListContactsScreenState extends State<ListContactsScreen> {
  List<Contact> contacts;
  final db = FirebaseDatabase.instance.reference().child("contacts");
  bool loading = false;

  @override
  void initState() {
    super.initState();
    this.contacts = this.widget.oldContacts;
    this.contacts.sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Widget build(BuildContext context) {
    Widget _getCard(Contact contactItem) {
      File image =
          contactItem.imgPath != null ? File(contactItem.imgPath) : null;
      String address =
          contactItem.publicPlace + ', nº' + contactItem.houseNumber;
      return Card(
        elevation: 5,
        child: ListTile(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext bc) {
                  return SimpleDialog(
                    children: [ContactDetails(contact: contactItem)],
                  );
                });
          },
          leading: image != null
              ? ClipRRect(
                  child: Image.file(
                    image,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  child: Icon(
                    Icons.camera_alt,
                  ),
                ),
          title: Row(
            children: [
              Icon(Icons.person),
              Text(contactItem.name),
            ],
          ),
          isThreeLine: true,
          subtitle: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.email),
                  Text(
                    contactItem.email,
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.place),
                  Text(
                    address,
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.phone),
                  Text(
                    contactItem.phone.toString(),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Future<void> _getContacts() async {
      setState(() {
        this.loading = true;
      });

      DataSnapshot data = await db.once();
      if (data.value == null) {
        setState(() {
          this.loading = false;
        });
        return [];
      }
      Map<String, dynamic> dynamicMaps =
          new Map<String, dynamic>.from(data.value);
      dynamicMaps.removeWhere(
          (key, value) => value['owner'] != this.widget.username.username);
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
      setState(() {
        this.contacts = newContacts;
        this.loading = false;
      });
    }

    _handleAddContact() {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => AddContactScreen(
            oldContacts: this.contacts,
            username: this.widget.username,
          ),
        ),
        (route) => false,
      );
    }

    _handleSearchContacts() {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => SearchContactScreen(
            oldContacts: this.contacts,
            username: this.widget.username,
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
                title: Text('Adicionar contato'),
                leading: Icon(Icons.person_add),
                onTap: _handleAddContact,
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
        title: Text("Lista de contatos"),
      ),
      body: Column(
        children: [
          this.loading
              ? Container(
                  child: CircularProgressIndicator(
                    value: null,
                  ),
                  alignment: Alignment.topCenter,
                )
              : Container(
                  child: IconButton(
                    icon: Icon(Icons.update),
                    onPressed: _getContacts,
                  ),
                  alignment: Alignment.topCenter,
                ),
          this.contacts.length == 0
              ? Container(
                  child: Text('Você não possui nenhum contato ainda!'),
                )
              : Expanded(
                  child: ListView.builder(
                      itemCount: this.contacts.length,
                      itemBuilder: (context, index) {
                        Contact contactItem = this.contacts[index];
                        if (index == 0 && this.contacts.length == 1) {
                          return Column(
                            children: [
                              Container(
                                child: Text(
                                  contactItem.name
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: TextStyle(fontSize: 30),
                                ),
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(left: 20),
                              ),
                              Divider(),
                              _getCard(contactItem),
                              Divider(),
                            ],
                          );
                        } else if (index == 0) {
                          if (contactItem.name.codeUnitAt(0) !=
                              this.contacts[index + 1].name.codeUnitAt(0)) {
                            return Column(
                              children: [
                                Container(
                                  child: Text(
                                    contactItem.name
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(left: 20),
                                ),
                                Divider(),
                                _getCard(contactItem),
                                Divider(),
                                Container(
                                  child: Text(
                                    this
                                        .contacts[index + 1]
                                        .name
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(left: 20),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                Container(
                                  child: Text(
                                    contactItem.name
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(left: 20),
                                ),
                                Divider(),
                                _getCard(contactItem),
                              ],
                            );
                          }
                        } else if (index < this.contacts.length - 1) {
                          if (contactItem.name.codeUnitAt(0) !=
                              this.contacts[index + 1].name.codeUnitAt(0)) {
                            return Column(
                              children: [
                                _getCard(contactItem),
                                Divider(),
                                Container(
                                  child: Text(
                                    this
                                        .contacts[index + 1]
                                        .name
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(left: 20),
                                ),
                              ],
                            );
                          } else {
                            return _getCard(contactItem);
                          }
                        } else if (index == this.contacts.length - 1) {
                          return Column(
                            children: [
                              _getCard(contactItem),
                              Divider(),
                            ],
                          );
                        } else {
                          return _getCard(contactItem);
                        }
                      }),
                ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }
}
