class ContactModel {
  final String name;
  final String imagepath;
  final String? objectId;

  ContactModel({
    required this.name,
    required this.imagepath,
    this.objectId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['name'] = name;
    data['imagepath'] = imagepath;

    return data;
  }
}
