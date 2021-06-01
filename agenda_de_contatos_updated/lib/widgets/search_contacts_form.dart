import 'package:flutter/material.dart';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import '../screens/update_contact_screen.dart';

import '../models/contact.dart';

class SearchContactsForm extends StatefulWidget {
  final String username;

  SearchContactsForm({this.username});

  @override
  _SearchContactsFormState createState() => _SearchContactsFormState();
}

class _SearchContactsFormState extends State<SearchContactsForm> {
  final _formKey = GlobalKey<FormState>();
  final db = FirebaseDatabase.instance.reference().child("contacts");
  String selectedFilter = 'id';
  List<Contact> findedContacts = [];

  bool loading = false;

  void showErrorMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void _handleSearch(String term) async {
      setState(() {
        this.loading = true;
      });
      DataSnapshot data;
      if (this.selectedFilter == 'id') {
        data = await db.orderByKey().equalTo(term).once();
      } else {
        data = await db.orderByChild("name").equalTo(term).once();
      }

      if (data.value == null) {
        setState(() {
          this.findedContacts = [];
          this.loading = false;
        });
      } else {
        Map<String, dynamic> dynamicMaps =
            new Map<String, dynamic>.from(data.value);
        dynamicMaps.removeWhere(
            (key, value) => value['owner'] != this.widget.username);
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
          this.findedContacts = newContacts;
          this.loading = false;
        });
      }
    }

    void _handleUpdate(Contact contact) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateContactScreen(
            contact: contact,
          ),
        ),
      );
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
          ),
        );
      }
      setState(() {
        this.findedContacts = [];
      });
    }

    void _handleDelete(Contact contact) async {
      final result = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Deletar contato'),
              content: Text('Tem certeza que deseja deletar esse contato?',
                  textAlign: TextAlign.center),
              actions: [
                TextButton(
                  child: Text('Não'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                TextButton(
                  child: Text('Sim'),
                  onPressed: () => Navigator.pop(context, true),
                )
              ],
            );
          });
      if (result) {
        db.child(contact.key).remove().then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Contato deletado com sucesso!'),
            ),
          );
        }).catchError((onError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(onError),
            ),
          );
        });
        setState(() {
          this.findedContacts = [];
        });
      }
    }

    return Form(
      key: this._formKey,
      child: Column(
        children: [
          Row(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints contraints) {
                    return Container(
                      child: TextFormField(
                        decoration: InputDecoration(
                          errorMaxLines: 2,
                          suffixIcon: Icon(Icons.search),
                          hintText: 'Digite um ' + this.selectedFilter,
                        ),
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: _handleSearch,
                      ),
                      width: MediaQuery.of(context).size.width * 0.60,
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.10,
                          right: MediaQuery.of(context).size.width * 0.05,
                          top: 20,
                          bottom: 20),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints contraints) {
                    return Container(
                        child: DropdownButton(
                          icon: Icon(Icons.filter_list),
                          value: this.selectedFilter,
                          items: <DropdownMenuItem<String>>[
                            DropdownMenuItem(
                              child: Text('Id'),
                              value: 'id',
                            ),
                            DropdownMenuItem(
                              child: Text('Nome'),
                              value: 'nome',
                            )
                          ],
                          onChanged: (value) {
                            setState(() {
                              this.selectedFilter = value;
                            });
                          },
                        ),
                        width: MediaQuery.of(context).size.width * 0.20,
                        margin: EdgeInsets.only(top: 20, bottom: 20));
                  },
                ),
              ),
            ],
          ),
          this.loading
              ? Container(
                  child: CircularProgressIndicator(
                    value: null,
                  ),
                )
              : this.findedContacts.length == 0
                  ? Container(
                      child: Text(
                        'Nenhum contato foi encontrado com esse ' +
                            this.selectedFilter +
                            ', tente mudar o termo procurado!',
                        textAlign: TextAlign.center,
                      ),
                      margin:
                          EdgeInsets.symmetric(vertical: 100, horizontal: 50),
                    )
                  : Expanded(
                      child: ListView.builder(
                          itemCount: this.findedContacts.length,
                          itemBuilder: (context, index) {
                            Contact contactItem = this.findedContacts[index];
                            File image = contactItem.imgPath != null
                                ? File(contactItem.imgPath)
                                : null;

                            return Container(
                              child: Card(
                                elevation: 5,
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  return ListTile(
                                    onTap: () {
                                      _handleUpdate(contactItem);
                                    },
                                    onLongPress: () {
                                      _handleDelete(contactItem);
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
                                        Text(contactItem.name)
                                      ],
                                    ),
                                    isThreeLine: true,
                                    subtitle: Container(
                                      child: Column(
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
                                                contactItem.publicPlace,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              margin: EdgeInsets.only(left: 20, right: 20),
                            );
                          }),
                    ),
        ],
      ),
    );
  }
}
