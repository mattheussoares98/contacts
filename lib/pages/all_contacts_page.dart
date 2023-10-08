import 'dart:io';
import 'package:contacts/models/contact_model.dart';
import 'package:contacts/pages/new_contact_page.dart';
import 'package:contacts/providers/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllContactsPage extends StatefulWidget {
  const AllContactsPage({super.key});

  @override
  State<AllContactsPage> createState() => _AllContactsPageState();
}

class _AllContactsPageState extends State<AllContactsPage> {
  Future<void> deleteContact(
      ContactProvider contactProvider, ContactModel contactModel) async {
    Navigator.of(context).pop();
    await contactProvider.deleteContact(
      context,
      contactModel.objectId!,
    );
  }

  @override
  Widget build(BuildContext context) {
    ContactProvider contactProvider = Provider.of(context, listen: true);
    return RefreshIndicator(
      onRefresh: () async {
        contactProvider.getContacts(context,
            notifyListenersWhenCleanContacts: true);
      },
      child: Center(
        child: ListView.builder(
          itemCount: contactProvider.contacts.length,
          itemBuilder: (context, index) {
            ContactModel contact = contactProvider.contacts[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: FileImage(
                            File(contact.imagepath),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        contact.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        contactProvider.updateSelectedData(
                          index: index,
                          imageFile: File(contact.imagepath),
                          name: contact.name,
                        );

                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              content: NewContactPage(
                                objectId: contact.objectId,
                                changePage: () {},
                                isEditingContact: true,
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.green,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                "Deseja realmente excluir o contato?",
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(100, 50),
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text("Não"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(100, 50),
                                      ),
                                      onPressed: () async {
                                        await deleteContact(
                                            contactProvider, contact);
                                      },
                                      child: const Text("Sim"),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
