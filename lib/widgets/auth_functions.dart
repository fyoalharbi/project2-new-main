import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> signUpWithEmailPassword(
    String email, String password) async {
  return await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
}

Future<UserCredential> signInWithEmailPassword(
    String email, String password) async {
  return await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}
