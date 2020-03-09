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

  Future<Map<String, dynamic>> getOwnProfile() {
    return Firestore.instance
        .collection("user")
        .document(firebaseUser.uid)
        .get()
        .then((data) {
      return data.data;
    });
  }

  /// Only if signed in
  Future<bool> checkIfProfileCreated() async {
    return (await getOwnProfile() != null);
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

  Future<bool> saveProfile(Map<String, dynamic> userData,
      {String videoPath}) async {
    if (videoPath != null) {
      StorageUploadTask uploadTaskVideo = FirebaseStorage()
          .ref()
          .child(firebaseUser.uid)
          .putFile(File(videoPath));
      await uploadTaskVideo.onComplete;
    }
    await Firestore.instance
        .collection("user")
        .document(firebaseUser.uid)
        .setData(userData, merge: true);
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
    await firebaseUser.delete();
    return true;
  }

  Future<void> sendFeedback(String message, {bool ownUid = false}) async {
    await Firestore.instance.collection("feedback").document().setData((!ownUid)
        ? {"message": message, "date": DateTime.now()}
        : {
            "message": message,
            "date": DateTime.now(),
            "uid": firebaseUser.uid
          });
  }

  reportUser(String uid) async {
    int reports = 0;
    DocumentReference reference =
        Firestore.instance.collection("report").document(uid);

    if ((await reference.get()).exists)
      reports = (await reference.get()).data["counter"];

    reference.setData({"counter": reports + 1}, merge: true);
  }

  likeUser(String uid) {
    Firestore.instance
        .collection("user")
        .document(firebaseUser.uid)
        .updateData({uid: true});
  }
}
