// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:contacts/api/bak4app_api.dart';
import 'package:contacts/components/snackbar_personalized.dart';
import 'package:contacts/models/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

class ContactProvider with ChangeNotifier {
  File? _imageFile;
  final TextEditingController _nameController = TextEditingController();
  XFile? _pickedFile;
  bool _isLoadingAddPhoto = false;
  bool _isLoadingGetContacts = false;
  bool _isLoadingDeleteContact = false;
  bool _isLoadingUpdateContact = false;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<ContactModel> _contacts = [];
  String? _errorMessageAddContact;
  String? _errorMessageUpdateContact;
  String? _errorMessageDeleteContact;
  String? _errorMessageGetContact;

  String? get errorMessageAddContact => _errorMessageAddContact;
  String? get errorMessageUpdateContact => _errorMessageUpdateContact;
  String? get errorMessageDeleteContact => _errorMessageDeleteContact;
  String? get errorMessageGetContact => _errorMessageGetContact;
  TextEditingController get nameController => _nameController;
  bool get isLoadingAddPhoto => _isLoadingAddPhoto;
  bool get isLoadingGetContacts => _isLoadingGetContacts;
  bool get isLoadingDeleteContact => _isLoadingDeleteContact;
  bool get isLoadingUpdateContact => _isLoadingUpdateContact;
  XFile? get pickedFile => _pickedFile;
  File? get imageFile => _imageFile;
  List<ContactModel> get contacts => [..._contacts];

  Future<void> takePhoto() async {
    _pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (_pickedFile != null) {
      _imageFile = File(_pickedFile!.path);
      notifyListeners();

      // Salvar a imagem na galeria usando o gallery_saver
      final result = await GallerySaver.saveImage(_imageFile!.path);

      if (result == true) {
        debugPrint("Imagem salva com sucesso na galeria!");
      } else {
        debugPrint("Falha ao salvar imagem na galeria.");
      }
    }
    notifyListeners();
  }

  Future pickImageByGallery() async {
    _pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (_pickedFile != null) {
      _imageFile = File(_pickedFile!.path);
    }
    notifyListeners();
  }

  void clearData() {
    nameController.clear();
    _pickedFile = null;
    _imageFile = null;
  }

  Future<void> addContact({required BuildContext context}) async {
    _errorMessageAddContact = null;
    _isLoadingAddPhoto = true;
    notifyListeners();

    String? objectId;

    if (!formKey.currentState!.validate()) {
      _errorMessageAddContact = "Dados inválidos!";
      SnackbarPersonalized.snackBar(
        context: context,
        message: _errorMessageAddContact!,
      );
    } else if (_pickedFile == null) {
      _errorMessageAddContact = "Insira uma foto!";
      SnackbarPersonalized.snackBar(
        context: context,
        message: _errorMessageAddContact!,
      );
    } else {
      try {
        objectId = await Back4appApi.addContactAndReturnId(
          contactModel: ContactModel(
            name: nameController.text,
            imagepath: _pickedFile!.path,
          ),
        );

        if (objectId != null) {
          _contacts.add(
            ContactModel(
              name: nameController.text,
              imagepath: _pickedFile!.path,
              objectId: objectId,
            ),
          );
          clearData();
        }
      } catch (e) {
        _errorMessageAddContact =
            "Ocorreu um erro não esperado para adicionar o contato!";
        SnackbarPersonalized.snackBar(
          context: context,
          message: _errorMessageAddContact!,
        );
      }
    }

    _isLoadingAddPhoto = false;

    notifyListeners();
  }

  Future<void> updateContact({
    required BuildContext context,
    required String objectId,
  }) async {
    _isLoadingUpdateContact = true;
    _errorMessageAddContact = null;
    notifyListeners();

    ContactModel contactModel = ContactModel(
      name: _nameController.text,
      imagepath: imageFile!.path,
      objectId: objectId,
    );

    try {
      _errorMessageAddContact =
          await Back4appApi.updateContact(contactModel: contactModel);

      if (_errorMessageAddContact == null) {
        int index = _contacts
            .indexWhere((element) => element.objectId == contactModel.objectId);

        if (index != -1) {
          _contacts[index] = contactModel;
        }
      } else {
        SnackbarPersonalized.snackBar(
          context: context,
          message: _errorMessageAddContact!,
        );
      }
    } catch (e) {
      _errorMessageAddContact =
          "Ocorreu um erro não esperado para alterar o contato!";
      SnackbarPersonalized.snackBar(
        context: context,
        message: _errorMessageAddContact!,
      );
    }

    _isLoadingUpdateContact = false;
    notifyListeners();
  }

  void updateSelectedData({
    required File imageFile,
    required String name,
    required int index,
  }) {
    _imageFile = imageFile;
    nameController.text = name;
    notifyListeners();
  }

  Future<void> getContacts(BuildContext context) async {
    _contacts.clear();
    _isLoadingGetContacts = true;

    try {
      _contacts = await Back4appApi.getContacts();
    } catch (e) {
      _errorMessageGetContact =
          "Ocorreu um erro não esperado para alterar o contato!";
      SnackbarPersonalized.snackBar(
        context: context,
        message: _errorMessageAddContact!,
      );
    }

    _isLoadingGetContacts = false;
    notifyListeners();
  }

  Future<void> deleteContact(BuildContext context, String objectId) async {
    _isLoadingDeleteContact = true;
    _errorMessageDeleteContact = null;
    notifyListeners();

    try {
      await Back4appApi.deleteContact(objectId: objectId);

      _contacts.removeWhere((element) => element.objectId == objectId);

      SnackbarPersonalized.snackBar(
        context: context,
        message: "Contato excluído com sucesso!",
        backgroundColor: Colors.green,
      );
    } catch (e) {
      _errorMessageDeleteContact =
          "Ocorreu um erro não esperado para alterar o contato!";
      SnackbarPersonalized.snackBar(
        context: context,
        message: _errorMessageDeleteContact!,
      );
    }

    _isLoadingDeleteContact = false;
    notifyListeners();
  }
}
