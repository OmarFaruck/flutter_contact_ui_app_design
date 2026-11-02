class Contact {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final int isFavorite;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.isFavorite = 0,
  });

  // Convert Object to Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'is_favorite': isFavorite,
    };
  }

  // Convert Map to Object
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      isFavorite: map['is_favorite'],
    );
  }
}