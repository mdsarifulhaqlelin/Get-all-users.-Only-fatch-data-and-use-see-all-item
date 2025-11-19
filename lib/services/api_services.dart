import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mrz/models/models_class.dart';
import '../models/user_response.dart';

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com/users';
  static const int _limit = 50;

  Future<List<User>> fetchAllUsers() async {
    final allUsers = <User>[];
    int skip = 0;
    int total = 0;
    

    do {
      final response = await http.get(
        Uri.parse('$_baseUrl?limit=$_limit&skip=$skip'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userResponse = UserResponse.fromJson(data);
        allUsers.addAll(userResponse.users);
        total = userResponse.total;
        skip += _limit;
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } while (skip < total);

    return allUsers;
  }
}

// হ্যাঁ, এই কোড অনেক উপায়ে লেখা যায়। আসুন কিছু বিকল্প দেখি:
// বিকল্প ১: for লুপ ব্যবহার করে (আরও পড়তে সহজ)


// Future<List<User>> fetchAllUsers() async {
//   // প্রথমে শুধু মোট সংখ্যা জেনে নিই
//   final firstResponse = await http.get(Uri.parse('$_baseUrl?limit=1&skip=0'));
//   final total = (jsonDecode(firstResponse.body))['total'] as int;
  
//   final allUsers = <User>[];
  
//   // এখন for লুপ চালাই
//   for (int skip = 0; skip < total; skip += _limit) {
//     final response = await http.get(Uri.parse('$_baseUrl?limit=$_limit&skip=$skip'));
//     final data = jsonDecode(response.body);
//     final userResponse = UserResponse.fromJson(data);
//     allUsers.addAll(userResponse.users);
//   }
  
//   return allUsers;
// }