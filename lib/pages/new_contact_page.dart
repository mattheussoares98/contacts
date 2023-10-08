import 'package:contacts/components/snackbar_personalized.dart';
import 'package:contacts/providers/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewContactPage extends StatefulWidget {
  final Function changePage;
  final bool? isEditingContact;
  final String? objectId;
  const NewContactPage({
    this.isEditingContact = false,
    this.objectId,
    required this.changePage,
    super.key,
  });

  @override
  State<NewContactPage> createState() => _NewContactPageState();
}

class _NewContactPageState extends State<NewContactPage> {
  Widget _backgroundImage(ContactProvider contactProvider) {
    if (contactProvider.isLoadingAddPhoto) {
      return const Padding(
        padding: EdgeInsets.all(15.0),
        child: CircularProgressIndicator(),
      );
    } else if (contactProvider.imageFile == null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          "Selecione a imagem",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
    } else {
      return Image.file(
        contactProvider.imageFile!,
        fit: BoxFit.cover,
      );
    }
  }

  Future<void> addContact(ContactProvider contactProvider) async {
    FocusScope.of(context).unfocus();
    await contactProvider.addContact(context: context);

    if (contactProvider.errorMessageAddContact == null) {
      widget.changePage();
      if (!mounted) return;
      SnackbarPersonalized.snackBar(
        context: context,
        message: "Contato adicionado com sucesso",
        backgroundColor: Theme.of(context).colorScheme.primary,
      );
    }
  }

  Future<void> updateContact(
    ContactProvider contactProvider,
    String objectId,
  ) async {
    FocusScope.of(context).unfocus();
    await contactProvider.updateContact(
      context: context,
      objectId: objectId,
    );

    if (contactProvider.errorMessageUpdateContact == null) {
      widget.changePage();
      if (!mounted) return;
      SnackbarPersonalized.snackBar(
        context: context,
        message: "Contato alterado com sucesso",
        backgroundColor: Theme.of(context).colorScheme.primary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ContactProvider contactProvider = Provider.of(context, listen: true);
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
              width: 100,
              height: 100,
              child: ClipOval(
                child: Container(
                  color: Colors.grey[400],
                  child: _backgroundImage(contactProvider),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: contactProvider.isLoadingAddPhoto
                          ? null
                          : () async {
                              await contactProvider.takePhoto();
                            },
                      child: const FittedBox(
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt),
                            SizedBox(width: 5),
                            Text(
                              "Tirar foto",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: contactProvider.isLoadingAddPhoto
                          ? null
                          : () async {
                              await contactProvider.pickImageByGallery();
                            },
                      child: const FittedBox(
                        child: Row(
                          children: [
                            Icon(Icons.image_search),
                            SizedBox(width: 5),
                            Text(
                              "Escolher imagem",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: contactProvider.formKey,
                child: TextFormField(
                  enabled: contactProvider.isLoadingAddPhoto ? false : true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Digite o nome!";
                    } else if (value.length < 3) {
                      return "Nome muito pequeno!";
                    } else {
                      return null;
                    }
                  },
                  controller: contactProvider.nameController,
                  decoration: InputDecoration(
                    hintText: "Nome",
                    labelText: "Nome",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    labelStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.italic,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.normal,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        style: BorderStyle.solid,
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        style: BorderStyle.solid,
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        style: BorderStyle.solid,
                        width: 1,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: contactProvider.isLoadingAddPhoto
                    ? null
                    : () async {
                        if (widget.isEditingContact!) {
                          await updateContact(
                            contactProvider,
                            widget.objectId!,
                          );
                        } else {
                          await addContact(contactProvider);
                        }
                      },
                child: Text(
                  widget.isEditingContact!
                      ? "Alterar contato"
                      : "Adicionar contato",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
