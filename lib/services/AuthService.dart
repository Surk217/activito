import 'package:activito/models/ActivitoUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'Server.dart';

enum SignInMethods { GOOGLE, FACEBOOK, NONE, EMAIL }

class AuthService {
  static FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static ActivitoUser? currentUser = null;

  static SignInMethods _signInMethod = SignInMethods.NONE;

  static Future<UserCredential?> signInWithGoogle() async {
    GoogleSignInAccount? userGoogleLoginAccount =
        await GoogleSignIn(scopes: ['email']).signIn();

    GoogleSignInAuthentication googleSignInAuth =
        await userGoogleLoginAccount!.authentication;

    AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuth.idToken,
        accessToken: googleSignInAuth.accessToken);

    UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(authCredential);

    return userCredential;
  }

  static Future<void> loginUser(String uid) async {
    final user = await Server.getUser(uid);
    _setCurrentUser(user);
  }

  static Future createAndLoginUser(String uid, String? email) async {
    if (email == null || email.isEmpty) email = "null";
    final user = await Server.createUser(uid, email);
    _setCurrentUser(user);
  }

  static String getCurrentFirebaseUserId() => _firebaseAuth.currentUser!.uid;

  static void _setCurrentUser(ActivitoUser user) {
    currentUser = user;
  }

  static void logout() {
    _firebaseAuth.signOut();
    currentUser = null;
  }

  static checkAndLoginUser() async {
    if(_firebaseAuth.currentUser != null)
      await loginUser(_firebaseAuth.currentUser!.uid);
  }

  static String getCurrentUserId() => currentUser!.id;
}
