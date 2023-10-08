import 'dart:convert';
import 'package:contacts/models/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Back4appApi {
  static const _url = "https://parseapi.back4app.com/classes/contacts";
  static const _headers = {
    'X-Parse-Application-Id': 'K7xfYZNGnvv63dTQZOaI5faUiGBBkcRi5oyDL8Kl',
    'X-Parse-REST-API-Key': '2OVqgXBoHfIpo3WaiplCLWqoQubsUAiimHlKGpdF',
    'Content-Type': 'application/json'
  };

  static Future<void> addContact() async {}

  static Future<String?> addContactAndReturnId({
    required ContactModel contactModel,
  }) async {
    String? idInBack4app;
    try {
      var request = http.Request('POST', Uri.parse(_url));
      request.body = json.encode(contactModel);
      request.headers.addAll(_headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 201) {
        String responseInString = await response.stream.bytesToString();
        Map responseInMap = json.decode(responseInString);

        idInBack4app = responseInMap["objectId"];
      }
    } catch (e) {
      debugPrint("Erro para adicionar o CEP: $e");
    }

    return idInBack4app;
  }

  static Future<String?> updateContact({
    required ContactModel contactModel,
  }) async {
    String? errorMessage;

    try {
      var request =
          http.Request('PUT', Uri.parse('$_url/${contactModel.objectId}'));
      request.body = json.encode(contactModel);
      request.headers.addAll(_headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseInString = await response.stream.bytesToString();
        debugPrint(responseInString);
      } else {
        if (response.reasonPhrase != null) {
          errorMessage = response.reasonPhrase!;
        }
        debugPrint(response.reasonPhrase);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return errorMessage;
  }

  static Future<List<ContactModel>> getContacts() async {
    List<ContactModel> contacts = [];

    try {
      var headers = {
        'X-Parse-Application-Id': 'K7xfYZNGnvv63dTQZOaI5faUiGBBkcRi5oyDL8Kl',
        'X-Parse-REST-API-Key': '2OVqgXBoHfIpo3WaiplCLWqoQubsUAiimHlKGpdF'
      };
      var request = http.Request('GET', Uri.parse(_url));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseInString = await response.stream.bytesToString();
        Map responseInMap = json.decode(responseInString);

        List results = responseInMap["results"];

        for (var element in results) {
          contacts.add(
            ContactModel(
              name: element["name"],
              imagepath: element["imagepath"],
              objectId: element["objectId"],
            ),
          );
        }

        debugPrint(responseInString);
      } else {
        debugPrint(response.reasonPhrase);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return contacts;
  }

  static Future<bool> deleteContact({
    required String objectId,
  }) async {
    bool deletedCep = false;
    var request = http.Request('DELETE', Uri.parse('$_url/$objectId'));
    request.headers.addAll(_headers);

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        debugPrint(await response.stream.bytesToString());
        deletedCep = true;
      } else {
        debugPrint(response.reasonPhrase);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return deletedCep;
  }
}
