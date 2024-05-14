import 'dart:math';

import 'package:cargo_app/services/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createNewUser(String email, String password) async {
    try {
      final credidentials = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credidentials.user;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<User?> signInUser(String email, String password,UserProvider userProvider) async {
     
    try {
      final credidentials = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
     
    userProvider.setUserId(credidentials.user!.uid);
      return credidentials.user;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> signOutUser() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
