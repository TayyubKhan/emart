class UserModel {
  final String name;
  final String email;
  final String mobileNumber;

  UserModel({
    required this.name,
    required this.email,
    required this.mobileNumber,
  });

  // Method to convert the object to a map (useful for APIs or databases)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'mobileNumber': mobileNumber,
    };
  }

  // Factory constructor to create an object from a map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, mobileNumber: $mobileNumber)';
  }
}
