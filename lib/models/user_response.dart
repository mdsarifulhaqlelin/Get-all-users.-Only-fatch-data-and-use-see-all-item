import 'package:mrz/models/models_class.dart';

class UserResponse {
  final List<User> users;
  final int total;
  final int skip;
  final int limit;

  UserResponse({
    required this.users,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      users: (json['users'] as List)
          .map((user) => User.fromJson(user))
          .toList(),
      total: json['total'] ?? 0,
      skip: json['skip'] ?? 0,
      limit: json['limit'] ?? 0,
    );
  }
}