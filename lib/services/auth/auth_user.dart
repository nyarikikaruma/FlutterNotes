import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';

@immutable
class AuthUser{
  final String? email;
  final bool isEmailVerified;
  const AuthUser({
    required this.isEmailVerified,
    required this.email,
    });

factory AuthUser.fromFirebase(User user){
  return AuthUser(
    isEmailVerified: user.emailVerified,
    email: user.email
    );
}
}