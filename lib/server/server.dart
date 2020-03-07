import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Userprofile
/*
{
  "name": firstName,
  "age": userAge,
  "gender": gender,
  "state": selectedState,
  "country": selectedCountry,
  "image": await File(await getSelfiePath())
      .readAsString(encoding: Encoding.getByName("LATIN1")),
  "minAge": minAge,
  "maxAge": maxAge,
}
*/

class Server {
  static final Server instance = Server._internal();
  factory Server() => instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;
  Server._internal() {}

  // Return true if signed in and profile is created
  Future<bool> signIn() async {
    return (await _googleSignIn.isSignedIn()) &&
        (await handleSignIn()) &&
        (await checkIfProfileCreated());
  }

  /// Only if signed in
  Future<bool> checkIfProfileCreated() async {
    DocumentSnapshot ds = await Firestore.instance
        .collection("user")
        .document(firebaseUser.uid)
        .get();
    return (ds.data != null);
  }

  Future<bool> handleSignIn() async {
    try {
      GoogleSignInAccount googleUser;
      if (await _googleSignIn.isSignedIn())
        googleUser = await _googleSignIn.signInSilently();
      else
        googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      firebaseUser = (await _auth.signInWithCredential(credential)).user;
    } catch (_) {
      return false;
    }
    return true;
  }

  Future<bool> createProfile(
      Map<String, dynamic> userData, String videoPath) async {
    print("profile size: " + userData.toString().length.toString());
    Firestore.instance
        .collection("user")
        .document(firebaseUser.uid)
        .setData(userData);
    StorageUploadTask uploadTaskVideo = FirebaseStorage()
        .ref()
        .child(firebaseUser.uid)
        .putFile(File(videoPath));
    await uploadTaskVideo.onComplete;
    return true;
  }

  Future<Map<String, dynamic>> recomendUser() async {
    // For test return own user
    Map<String, dynamic> data;
    DocumentSnapshot ds = await Firestore.instance
        .collection("user")
        .document(firebaseUser.uid)
        .get();
    data = ds.data;
    data["uid"] = ds.documentID;
    return data;
  }

  Future<String> getVideoUrl(String uid) {
    return FirebaseStorage()
        .ref()
        .child(uid)
        .getDownloadURL()
        .catchError((_) {})
        .then((url) {
      return url;
    });
  }

  Future<bool> deleteProfile() async {
    await Firestore.instance
        .collection("user")
        .document(firebaseUser.uid)
        .delete();
    await FirebaseStorage().ref().child(firebaseUser.uid).delete();
    return true;
  }
}
