import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Widget buildTextField({
  required TextEditingController controller,
  required Size size,
  required String labelText,
  required Icon icon,
  bool obscureText = false,
}) {
  return SizedBox(
    width: size.width * 0.25,
    height: 50.0,
    child: TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: icon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    ),
  );
}

void navigateTo(BuildContext context, String routeName) {
  Navigator.pushNamed(context, routeName);
}

Future<UserCredential> signInWithGoogle() async {
  String clientID =
      '341374582141-7c38m7tj4tbl1bl1ug96t2lk6rg5q7ob.apps.googleusercontent.com';
  final GoogleSignInAccount? googleUser =
      await GoogleSignIn(clientId: clientID).signIn();

  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}

Future<void> signInWithEmail(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } catch (e) {
    rethrow;
  }
}

Future<void> signUpWithEmail(String email, String password) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  } catch (e) {
    rethrow;
  }
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

