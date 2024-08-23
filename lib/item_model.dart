class Item {
  final int? id;
  final String name;
  final String location;

  Item({this.id, required this.name, required this.location});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      location: map['location'],
    );
  }
}
