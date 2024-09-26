import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/user_screens/user.dart';
import 'package:flutter_application_1/utility/auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> addUser(User user) async {
    try {
      await signUpWithEmail(user.email, user.password)
          .then((userCredential) async {
        await userCredential?.sendEmailVerification();
      });
      await _firestore.collection('users').doc(user.email).set(user.toMap());
      print("User Added");
      return true;
    } catch (error) {
      print("Failed to add user: $error");
      return false;
    }
  }

  Future<bool> userExists(String email) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(email).get();
      return doc.exists; // Return true if the document exists
    } catch (error) {
      print("Failed to check if user exists: $error");
      return false; // In case of an error, assume the user does not exist
    }
  }

  Future<User?> getUser(String email) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(email).get();
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (error) {
      print("Failed to get user: $error");
    }
    return null;
  }

  Future<bool> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.email).update(user.toMap());
      print("User Updated");
      return true;
    } catch (error) {
      print("Failed to update user: $error");
      return false;
    }
  }
}
