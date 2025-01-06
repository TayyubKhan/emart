// import 'dart:convert' show jsonDecode, jsonEncode;
// import 'dart:developer';
// import 'package:credit_app/Model/cardDetailSendModel.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:hive/hive.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dio/dio.dart';
// import '../main.dart';
//
// class SendMessageRepo {
//   Future<void> sendMessage(
//     String username,
//     message,
//     uid,
//   ) async {
//     try {
//       String uidd = '';
//       if (uid == 'null') {
//         uidd = 'null';
//       } else {
//         uidd = uid;
//       }
//       var response = await http.post(
//         Uri.parse('https://csrwpt.in//api/messages.php?type=POST'),
//         body: {
//           'u_id': uidd,
//           'name': username,
//           'message': message,
//         },
//       );
//       print(response.body);
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         log(data.toString());
//         return data;
//       } else {
//         // Handle
//         log(response.statusCode.toString());
//         await saveMessageLocally(username, message);
//         throw Exception('Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       await saveMessageLocally(username, message);
//       log(e.toString());
//     }
//   }
//
//   Future<void> saveMessageLocally(String address, String body) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String> messages = prefs.getStringList('messages') ?? [];
//     messages.add('$address|$body');
//     await prefs.setStringList('messages', messages);
//   }
// }
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendMessageRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(
      String username, String message, String uid, String timestamp) async {
    try {
      // Get current timestamp

      // Prepare the message data
      Map<String, dynamic> messageData = {
        'name': username,
        'message': message,
        'timestamp': timestamp,
      };
      String id = DateTime.now().millisecondsSinceEpoch.toString();
      // Send the message to Firestore under the document named after the UID
      await _firestore
          .collection('CSRWPT')
          .doc(uid)
          .collection('csrwpt_messages')
          .doc(id)
          .set(messageData);
    } catch (e) {
      // If an error occurs during the request, save the message locally
      await saveMessageLocally(username, message, timestamp);
      log(e.toString());
    }
  }

  Future<void> saveMessageLocally(
      String username, String message, String timestamp) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> messages = [];

      // Check if there are already saved messages
      String? storedMessages = prefs.getString('messages');
      if (storedMessages != null && storedMessages.isNotEmpty) {
        messages = List<Map<String, dynamic>>.from(jsonDecode(storedMessages));
      }

      // Add the new message to the list
      messages.add({
        'name': username,
        'message': message,
        'timestamp': timestamp,
      });

      // Save the updated list of messages
      await prefs.setString('messages', jsonEncode(messages));
    } catch (e) {
      log('Error saving message locally: $e');
    }
  }
}
