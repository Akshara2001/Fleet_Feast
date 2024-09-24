import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utility/common.dart';
import 'package:flutter_application_1/screens/user_screens/user_serivice.dart';

// Initialize FirebaseAuth instance
final FirebaseAuth _auth = FirebaseAuth.instance;

/**
 * Signs up a user with email and password
 * @param email - The user's email address
 * @param password - The user's password
 */
Future<User?> signUpWithEmail(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Signed in
    User? user = userCredential.user;
    print("User signed up: $user");
    return user;
  } catch (error) {
    print("Error signing up: $error");
    // Handle errors here
    rethrow;
  }
}

Future<void> resetPassword(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    print('Password reset email sent');
  } catch (e) {
    print('Error: $e');
    // Handle errors, such as invalid email or network issues
  }
}

/**
 * Signs in a user with email and password
 * @param email - The user's email address
 * @param password - The user's password
 */
Future<User?> signInWithEmail(
    String email, String password, BuildContext buildContext) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (!user!.emailVerified) {
      showDialogMessage(buildContext, "Verification Required",
          "Please complete the verification process by clicking on the link sent to your email. Thank you!");
      throw "email not verified";
    }

    final UserService userService = UserService();
    await userService.getUser(email).then((user) {
      if (!user!.isApproved) {
        showDialogMessage(
            buildContext, "Email Not Verified", "Email Not Verified By Admin");
        throw "email not verified by admin";
      }
    });

    print("User signed in: $user");
    await saveUserDataToLocal({"email": email, "password": password});
    return user;
  } catch (error) {
    print("Error signing in: $error");

    if (error is FirebaseAuthException) {
      showDialogMessage(
          buildContext, "Error", error.message ?? "An unknown error occurred.");
    }

    rethrow;
  }
}

// Function to show dialog messages
void showDialogMessage(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
