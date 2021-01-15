import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:memoree_client/app/models/constants.dart';
import 'package:memoree_client/app/models/user.dart';
import 'package:memoree_client/app/services/search.dart';

class FirebaseAuthService {
  final auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({auth.FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();

  User _userFromFirebase(auth.User user) {
    if (user == null) {
      return null;
    }
    return User(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Stream<User> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  Future<User> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;
    final credential = auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final authResult = await _firebaseAuth.signInWithCredential(credential);
    User signedIn = _userFromFirebase(authResult.user);

    // Check if user is allowed to access the server
    final isAllowed = await SearchService.isWhitelisted(signedIn.email);
    if(!isAllowed)
    {
      await _googleSignIn.disconnect();
      await _firebaseAuth.signOut();
      throw(signedIn.email + PageErrors.no_access);
    }

    return signedIn;
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    return _firebaseAuth.signOut();
  }

  Future<User> currentUser() async {
    final user = _firebaseAuth.currentUser;
    return _userFromFirebase(user);
  }
}