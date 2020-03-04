import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Server {
  static final Server instance = Server._internal();
  factory Server() => instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;
  Server._internal() {}

  Future<bool> checkIfSignedIn() async {
    if (await handleSignIn()) {
      DocumentSnapshot ds = await Firestore.instance
          .collection("user")
          .document(firebaseUser.uid)
          .get();
      if (ds.data.isNotEmpty) return true;
    }
    return false;
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
    print("length " + userData.toString().length.toString());
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
}
