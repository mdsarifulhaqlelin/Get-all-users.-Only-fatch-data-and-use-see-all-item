class User {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? username;
  final String? role;
  final String? phone;
  final String? image;
  final Hair? hair;
  final Address? address;

  User({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.username,
    this.role,
    this.phone,
    this.image,
    this.hair,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      username: json['username'],
      role: json['role'],
      phone: json['phone'],
      image: json['image'],
      hair: json['hair'] != null ? Hair.fromJson(json['hair']) : null,
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }
}

class Hair {
  final String? color;
  final String? type;
  Hair({this.color, this.type});
  
  factory Hair.fromJson(Map<String, dynamic> json) {
    return Hair(
      color: json['color'],
      type: json['type'],
    );
  }
}

class Address {
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  
  Address({this.address, this.city, this.state, this.country});
  
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
    );
  }
}