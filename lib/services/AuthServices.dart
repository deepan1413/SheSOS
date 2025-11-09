import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:she_sos/models/user_model.dart';

class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool isInitialize = false;

  static Future<void> initSignIn() async {
    if (!isInitialize) {
      await _googleSignIn.initialize(
        serverClientId:
            '987757075985-cid9t8cn1i0pdr9qbg33mbhv89lkf55v.apps.googleusercontent.com',
      );
      isInitialize = true;
    }
  }

  /// ✅ Sign in with Google, store/update Firestore using UserModel
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      await initSignIn();

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      /* ✅ Fetch Google auth tokens */
      final idToken = googleUser.authentication.idToken;
      final authorizationClient = googleUser.authorizationClient;

      GoogleSignInClientAuthorization? authorization =
          await authorizationClient.authorizationForScopes(
        ['email', 'profile'],
      );

      final accessToken = authorization?.accessToken;

      if (accessToken == null) {
        final authorization2 =
            await authorizationClient.authorizationForScopes(
          ['email', 'profile'],
        );

        if (authorization2?.accessToken == null) {
          throw FirebaseAuthException(
              code: "error", message: "Google token error");
        }
      }

      /* ✅ Firebase login credential */
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null) {
        /// ✅ Sync FirebaseAuth profile
        await user.updateDisplayName(googleUser.displayName ?? "");
        await user.updatePhotoURL(googleUser.photoUrl ?? "");

        /// ✅ Build Firestore record using your Model
        final userDoc =
            FirebaseFirestore.instance.collection("users").doc(user.uid);

        final exists = await userDoc.get();

        if (!exists.exists) {
          /// ✅ Default UserModel for Google users
          final newUser = UserModel(
            userId: user.uid,
            name: googleUser.displayName ?? "",
            emailId: googleUser.email,
            phoneNumber: user.phoneNumber ?? "",
            address: "",
            emergencyContacts: [],
            profilePicture: googleUser.photoUrl ?? "",
            isVolunteer: false,
            currentLocation: null,
            isSafe: true,
          );

          await userDoc.set(newUser.toMap());
        }
      }

      return userCredential;
    } catch (e) {
      print("Google Sign-In Error: $e");
      rethrow;
    }
  }

  /// ✅ Sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
      throw e;
    }
  }

  static User? getCurrentUser() => _auth.currentUser;
}
