import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:developer';

import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/contact.dart';

class ContactDetails extends StatefulWidget {
  final Contact contact;

  ContactDetails({this.contact});

  @override
  _ContactDetailsState createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  DateTime selectedDate = DateTime.now();

  static const _scopes = const [CalendarApi.calendarScope];

  Future<bool> _addBirthday() async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      cancelText: 'Cancelar',
      helpText: 'Selecione a data para o aniversário',
    );
    if (picked != null) {
      DateTime endPicked =
          picked.add(Duration(hours: 23, minutes: 59, seconds: 59));

      var _clientID = new ClientId(
          "229672269179-3jgqomf8f3jfm6edd415ql87siji1oe8.apps.googleusercontent.com",
          "");
      clientViaUserConsent(_clientID, _scopes, prompt)
          .then((AuthClient client) {
        var calendar = CalendarApi(client);
        calendar.calendarList
            .list()
            .then((value) => print("VAL________$value"));

        String calendarId = "primary";
        Event event = Event(); // Create object of event

        event.summary = 'Aniversário de ' + this.widget.contact.name;

        EventDateTime start = new EventDateTime();
        start.dateTime = picked;
        start.timeZone = "GMT-03:00";
        event.start = start;

        EventDateTime end = new EventDateTime();
        end.timeZone = "GMT-03:00";
        end.dateTime = endPicked;
        event.end = end;

        event.recurrence = ["RRULE:FREQ=YEARLY"];
        try {
          calendar.events.insert(event, calendarId).then((value) {
            print("ADDEDDD_________________${value.status}");
            if (value.status == "confirmed") {
              return true;
            } else {
              return false;
            }
          });
        } catch (e) {
          return false;
        }
      });
    }
    return false;
  }

  void prompt(String url) async {
    print("Please go to the following URL and grant access:");
    print("  => $url");
    print("");

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    File _image = this.widget.contact.imgPath != null
        ? File(this.widget.contact.imgPath)
        : null;
    String address = 'nº' + this.widget.contact.houseNumber;
    address += this.widget.contact.complement != null
        ? ', ' + this.widget.contact.complement
        : '';

    return Column(
      children: [
        Container(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          margin: EdgeInsets.only(right: 10),
        ),
        CircleAvatar(
          radius: 55,
          child: _image != null
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
        Container(
          child: Row(
            children: [
              Container(
                child: Icon(Icons.person),
                margin: EdgeInsets.only(right: 10),
              ),
              Container(
                child: Text(this.widget.contact.name),
                margin: EdgeInsets.only(right: 30),
              ),
            ],
          ),
          margin: EdgeInsets.only(top: 20, left: 30),
        ),
        Container(
          child: Row(
            children: [
              Container(
                child: Icon(Icons.email),
                margin: EdgeInsets.only(right: 10),
              ),
              Container(
                child: Text(this.widget.contact.email),
              ),
            ],
          ),
          margin: EdgeInsets.only(top: 20, left: 30),
        ),
        Container(
          child: Row(
            children: [
              Container(
                child: Icon(Icons.phone),
                margin: EdgeInsets.only(
                  right: 10,
                ),
              ),
              Container(
                child: Text(this.widget.contact.phone.toString()),
              ),
            ],
          ),
          margin: EdgeInsets.only(top: 20, left: 30),
        ),
        Card(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    child: Icon(Icons.location_on),
                    margin: EdgeInsets.only(
                      right: 10,
                      top: 10,
                    ),
                  ),
                  Container(
                    child: Text(this.widget.contact.publicPlace),
                  ),
                ],
              ),
              Container(
                child: Text(address),
                margin: EdgeInsets.only(left: 35),
              ),
              Container(
                child: Text(this.widget.contact.district),
                margin: EdgeInsets.only(top: 5, left: 35),
              ),
              Container(
                child: Text(this.widget.contact.city),
                margin: EdgeInsets.only(top: 5, left: 35),
              ),
              Container(
                child: Text(this.widget.contact.state),
                margin: EdgeInsets.only(top: 5, left: 35, bottom: 10),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: EdgeInsets.only(left: 30, right: 30, top: 20),
          elevation: 5,
        ),
        Container(
          child: IconButton(
              icon: Icon(Icons.date_range),
              onPressed: () async {
                bool result = await _addBirthday();
                if (result) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Aniversário adicionado com sucesso!'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('O aniversário não pode ser adicionado.'),
                    ),
                  );
                }
              }),
          margin: EdgeInsets.only(top: 20),
        ),
      ],
    );
  }
}
