import 'user.dart';

class Session {
  final String token;
  final AppUser user;
  final DateTime loginTime;

  const Session({
    required this.token,
    required this.user,
    required this.loginTime,
  });

  Session copyWith({AppUser? user}) {
    return Session(
      token: token,
      user: user ?? this.user,
      loginTime: loginTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'loginTime': loginTime.toIso8601String(),
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      token: json['token'] as String,
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      loginTime: DateTime.parse(json['loginTime'] as String),
    );
  }
}
