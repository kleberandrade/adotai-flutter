import 'package:firebase_auth/firebase_auth.dart';

class SigninRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<FirebaseUser> signInWithEmailAndPassword(
      {String email, String password}) async {
    final auth = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return auth.user;
  }

  Future signOut() async {
    await _firebaseAuth.signOut();
  }
}
