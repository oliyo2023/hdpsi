class User {
  final int id;
  final String username;
  final String name;
  final String email;
  final String phone;
  final String role;
  final int? storeId;
  final bool status;
  
  User({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.storeId,
    required this.status,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['ID'],
      username: json['Username'],
      name: json['Name'],
      email: json['Email'] ?? '',
      phone: json['Phone'] ?? '',
      role: json['Role'],
      storeId: json['StoreID'],
      status: json['Status'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Username': username,
      'Name': name,
      'Email': email,
      'Phone': phone,
      'Role': role,
      'StoreID': storeId,
      'Status': status,
    };
  }
}
