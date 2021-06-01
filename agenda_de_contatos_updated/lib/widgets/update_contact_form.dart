import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../models/contact.dart';

class UpdateContactForm extends StatefulWidget {
  final Contact contact;

  UpdateContactForm({this.contact});

  @override
  _UpdateContactFormState createState() => _UpdateContactFormState();
}

class _UpdateContactFormState extends State<UpdateContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _controllerForName = TextEditingController();
  final _controllerForZipCode = TextEditingController();
  final _controllerForPublicPlace = TextEditingController();
  final _controllerForDistrict = TextEditingController();
  final _controllerForCity = TextEditingController();
  final _controllerForState = TextEditingController();
  final _controllerForComplement = TextEditingController();
  final _controllerForHouseNumber = TextEditingController();
  final _controllerForPhone = TextEditingController();
  final _controllerForEmail = TextEditingController();
  final db = FirebaseDatabase.instance.reference().child("contacts");
  File _image;
  String _imagePath;

  @override
  void initState() {
    super.initState();
    this._controllerForName.text = this.widget.contact.name;
    this._controllerForEmail.text = this.widget.contact.email;
    this._controllerForPhone.text = this.widget.contact.phone.toString();
    this._controllerForCity.text = this.widget.contact.city;
    this._controllerForDistrict.text = this.widget.contact.district;
    this._controllerForComplement.text = this.widget.contact.complement;
    this._controllerForHouseNumber.text = this.widget.contact.houseNumber;
    this._controllerForCity.text = this.widget.contact.city;
    this._controllerForPublicPlace.text = this.widget.contact.publicPlace;
    this._controllerForState.text = this.widget.contact.state;
    this._controllerForZipCode.text = this.widget.contact.zipCode;
    if (this.widget.contact.imgPath != null) {
      this._imagePath = this.widget.contact.imgPath;
      this._image = File(this.widget.contact.imgPath);
    }
  }

  String _validateName(value) {
    String validationResult;

    if (value == null || value.isEmpty) {
      validationResult = 'Digite um nome para continuar';
    }

    return validationResult;
  }

  String _validatePhone(value) {
    String validationResult;

    if (value == null || value.isEmpty) {
      validationResult = 'Digite um telefone para continuar';
    }

    return validationResult;
  }

  String _validateEmail(value) {
    print(value);
    String validationResult;
    bool isValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);

    print(isValid);

    if (value == null || value.isEmpty) {
      validationResult = 'Digite um email para continuar';
    }

    if (!isValid) {
      validationResult = 'Insira um email válido. Exemplo: exemplo@teste.com';
    }

    return validationResult;
  }

  String _validatePublicPlace(value) {
    String validationResult;

    if (value == null || value.isEmpty) {
      validationResult = 'Digite um logradouro para continuar';
    }

    return validationResult;
  }

  String _validateDistrict(value) {
    String validationResult;
    if (value == null || value.isEmpty) {
      validationResult = 'Digite um bairro para continuar';
    }

    return validationResult;
  }

  String _validateCity(value) {
    String validationResult;
    if (value == null || value.isEmpty) {
      validationResult = 'Digite uma cidade para continuar';
    }

    return validationResult;
  }

  String _validateState(value) {
    String validationResult;
    if (value == null || value.isEmpty) {
      validationResult = 'Digite um estado para continuar';
    }

    return validationResult;
  }

  String _validateHouseNumber(value) {
    String validationResult;
    if (value == null || value.isEmpty) {
      validationResult = 'Digite um número para continuar';
    }

    return validationResult;
  }

  void _showLoadingIndicator() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext bc) {
          return Dialog(
            child: Column(
              children: [
                Container(
                  child: Text('Procurando endereço...'),
                  margin: EdgeInsets.only(
                    top: 20,
                  ),
                ),
                Container(
                  child: CircularProgressIndicator(
                    value: null,
                  ),
                  margin: EdgeInsets.only(
                    left: 100,
                    right: 100,
                    top: 50,
                    bottom: 50,
                  ),
                  height: 100,
                  width: 100,
                ),
              ],
              mainAxisSize: MainAxisSize.min,
            ),
          );
        });
  }

  void _getImage(ImageSource imgSource) async {
    final pickedFile = await ImagePicker().getImage(source: imgSource);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void _getAddress(String cep) async {
      _showLoadingIndicator();
      http.Response res =
          await http.get(Uri.parse("https://viacep.com.br/ws/${cep}/json/"));
      Navigator.of(context).pop();
      if (res.statusCode == 200) {
        Map<String, dynamic> responseJson = jsonDecode(res.body);
        if (responseJson['erro'] == null) {
          this._controllerForCity.text = responseJson['localidade'];
          this._controllerForPublicPlace.text = responseJson['logradouro'];
          this._controllerForDistrict.text = responseJson['bairro'];
          this._controllerForState.text = responseJson['uf'];
          this._controllerForComplement.text = responseJson['complemento'];
          this._controllerForZipCode.text = cep;
        }
      }
    }

    void _callPicker() {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return SafeArea(
              child: Container(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Galeria'),
                      onTap: () {
                        _getImage(ImageSource.gallery);
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.photo_camera),
                      title: Text('Câmera'),
                      onTap: () {
                        _getImage(ImageSource.camera);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          });
    }

    void _completeEdit() async {
      if (_formKey.currentState.validate()) {
        db.child(this.widget.contact.key).set({
          "name": this._controllerForName.text,
          "email": this._controllerForEmail.text,
          "publicPlace": this._controllerForPublicPlace.text,
          "district": this._controllerForDistrict.text,
          "city": this._controllerForCity.text,
          "state": this._controllerForState.text,
          "houseNumber": this._controllerForHouseNumber.text,
          "complement": this._controllerForComplement.text,
          "zipCode": this._controllerForZipCode.text,
          "phone": num.parse(this._controllerForPhone.text),
          "owner": this.widget.contact.owner,
          "imgPath": this._imagePath
        }).then((_) {
          Navigator.pop(context, 'Contato atualizado com sucesso!');
        }).catchError((onError) {
          Navigator.pop(context, onError);
        });
      }
    }

    void _cancelEdit() {
      Navigator.pop(context);
    }

    return Form(
      key: this._formKey,
      child: ListView(
        children: [
          Container(
            child: GestureDetector(
              onTap: _callPicker,
              child: CircleAvatar(
                radius: 55,
                child: this._image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.file(
                          _image,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        ),
                      )
                    : Container(
                        child: Icon(
                          Icons.camera_alt,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        width: 100,
                        height: 100,
                      ),
              ),
            ),
            margin: EdgeInsets.only(
              top: 50,
              bottom: 20,
            ),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForName,
              decoration: InputDecoration(
                labelText: 'Nome do contato',
                errorMaxLines: 2,
              ),
              validator: this._validateName,
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
          Container(
            child: TextFormField(
              controller: this._controllerForZipCode,
              decoration: InputDecoration(
                labelText: 'CEP',
                errorMaxLines: 2,
                prefixIcon: Icon(Icons.search),
              ),
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (value) {
                _getAddress(value);
              },
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForPublicPlace,
              decoration: InputDecoration(
                labelText: 'Logradouro',
                errorMaxLines: 2,
              ),
              enabled: this._controllerForPublicPlace.text != '' ? false : true,
              validator: this._validatePublicPlace,
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForDistrict,
              decoration: InputDecoration(
                labelText: 'Bairro',
                errorMaxLines: 2,
              ),
              enabled: this._controllerForDistrict.text != '' ? false : true,
              validator: this._validateDistrict,
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForHouseNumber,
              decoration: InputDecoration(
                labelText: 'Número',
                errorMaxLines: 2,
              ),
              enabled: this._controllerForHouseNumber.text != '' ? false : true,
              validator: this._validateHouseNumber,
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForComplement,
              decoration: InputDecoration(
                labelText: 'Complemento',
                errorMaxLines: 2,
              ),
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForCity,
              decoration: InputDecoration(
                labelText: 'Cidade',
                errorMaxLines: 2,
              ),
              enabled: this._controllerForCity.text != '' ? false : true,
              validator: this._validateCity,
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForState,
              decoration: InputDecoration(
                labelText: 'Estado',
                errorMaxLines: 2,
              ),
              enabled: this._controllerForState.text != '' ? false : true,
              validator: this._validateState,
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForPhone,
              decoration: InputDecoration(
                labelText: 'Telefone',
                errorMaxLines: 2,
              ),
              validator: this._validatePhone,
              keyboardType: TextInputType.phone,
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Row(
            children: [
              Container(
                child: ElevatedButton(
                  onPressed: _completeEdit,
                  child: Text('Editar contato'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                ),
                margin: EdgeInsets.only(
                  right: 20,
                  bottom: 50,
                ),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: _cancelEdit,
                  child: Text('Cancelar'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                ),
                margin: EdgeInsets.only(
                  bottom: 50,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
      ),
    );
  }
}
