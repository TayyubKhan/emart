class UserData {
  final String id; // Added id field
  final String name;
  final String card;
  final String date;
  final String mobile;
  final String email;
  final String dob;
  final int ceM;
  final int ceY;
  final int cvv;
  final int available;
  final String fcmToken; // Added fcmToken field

  UserData({
    required this.id,
    required this.name,
    required this.card,
    required this.date,
    required this.mobile,
    required this.email,
    required this.dob,
    required this.ceM,
    required this.ceY,
    required this.cvv,
    required this.available,
    required this.fcmToken,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'], // Adjust this according to your JSON structure
      name: json['name'],
      card: json['card'],
      date: json['date'],
      mobile: json['mobile'],
      email: json['email'],
      dob: json['dob'],
      ceM: json['ce_m'],
      ceY: json['ce_y'],
      cvv: json['cvv'],
      available: json['available'],
      fcmToken: json['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'card': card,
      'date': date,
      'mobile': mobile,
      'email': email,
      'dob': dob,
      'ce_m': ceM,
      'ce_y': ceY,
      'cvv': cvv,
      'available': available,
      'fcmToken': fcmToken,
    };
  }
}
