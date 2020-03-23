import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_match/utils/updateCheck.dart';

// Userprofile
/*
{
  "name": firstName,
  "age": userAge,
  "gender": gender,
  "state": selectedState,
  "country": selectedCountry,
  "maxAge": maxAge,
  "lastOnline": DateTime.now(),
  "seenUserDateOldest": DateTime.now(),
  "seenUserDateYoungest": DateTime.now(),
  "image":
      Base64Codec().encode(await File(await getSelfiePath()).readAsBytes()),
  "creationDate": DateTime.now()
}
*/

class Server {
  static final Server instance = Server._internal();
  factory Server() => instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;
  Map<String, dynamic> ownUserData = Map<String, dynamic>();

  Server._internal() {}

  // Return true if signed in and profile is created
  Future<bool> signIn() async {
    return (await _googleSignIn.isSignedIn()) &&
        (await handleSignIn()) &&
        (await checkIfProfileCreated() && (await checkVersion()));
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
      await _updateOwnUserData();
      await _updateLastOnline();
    } catch (_) {
      return false;
    }
    return true;
  }

  /// Only if signed in
  Future<bool> checkVersion() async {
    DocumentSnapshot ds = await Firestore.instance
        .collection("version")
        .document("version")
        .get();
    return (checkUpdateVersionNumber >= ds.data["minVersion"]);
  }

  _updateOwnUserData() async {
    ownUserData = (await Firestore.instance
            .collection("user")
            .document(firebaseUser.uid)
            .get())
        .data;
  }

  _updateLastOnline() async {
    await Firestore.instance
        .collection("user")
        .document(firebaseUser.uid)
        .updateData({"lastOnline": DateTime.now()});
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

  Future<bool> saveProfile(
      {Map<String, dynamic> userData, String videoPath}) async {
    if (videoPath != null) {
      StorageUploadTask uploadTaskVideo = FirebaseStorage()
          .ref()
          .child(firebaseUser.uid)
          .putFile(File(videoPath));
      await uploadTaskVideo.onComplete;
    }
    if (userData != null)
      await Firestore.instance
          .collection("user")
          .document(firebaseUser.uid)
          .setData(userData, merge: true);
    return true;
  }

  Future<Map<String, dynamic>> recomendUser() async {
    await _updateOwnUserData();
    Map<String, dynamic> data;
    List<DocumentSnapshot> ds;
    ds = (await Firestore.instance
            .collection("user")
            .limit(1)
            .where("creationDate",
                isGreaterThan: ownUserData["seenUserDateYoungest"])
            .orderBy("creationDate", descending: false)
            //.where("lastOnline", isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(days: 30)))
            //.where("gender", isEqualTo: !ownUserData["gender"])
            //.where("age", isGreaterThanOrEqualTo: ownUserData["minAge"])
            //.where("age", isLessThanOrEqualTo: ownUserData["maxAge"])
            .getDocuments())
        .documents;
    if (ds.length == 0)
      ds = (await Firestore.instance
              .collection("user")
              .limit(1)
              .where("creationDate",
                  isLessThan: ownUserData["seenUserDateOldest"])
              .orderBy("creationDate", descending: true)
              //.where("lastOnline", isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(days: 30)))
              //.where("gender", isEqualTo: !ownUserData["gender"])
              //.where("age", isGreaterThanOrEqualTo: ownUserData["minAge"])
              //.where("age", isLessThanOrEqualTo: ownUserData["maxAge"])
              .getDocuments())
          .documents;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (ds.length == 0)
      prefs.setBool("notifyNewUser", true);
    else
      prefs.setBool("notifyNewUser", false);

    data = ds.first.data;
    data["uid"] = ds.first.documentID;
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

  rateUser(String otherUserUid, bool like,
      {Timestamp otherUserProfileCreationDate}) {
    if (otherUserProfileCreationDate != null)
      Firestore.instance
          .collection("user")
          .document(firebaseUser.uid)
          .updateData({
        otherUserUid: like,
        (otherUserProfileCreationDate.millisecondsSinceEpoch <
                ownUserData["seenUserDateOldest"].millisecondsSinceEpoch)
            ? "seenUserDateOldest"
            : "seenUserDateYoungest": otherUserProfileCreationDate,
      });
    else
      Firestore.instance
          .collection("user")
          .document(firebaseUser.uid)
          .updateData({otherUserUid: like});
  }

  Stream<QuerySnapshot> likesProfileList() {
    return Firestore.instance
        .collection("user")
        .where(firebaseUser.uid, isEqualTo: true)
        .snapshots();
  }

  checkOwnUserLikedBack(String uid, bool condition) {
    if (ownUserData[uid] == condition || !condition && ownUserData[uid] == null)
      return true;
    else
      return false;
  }

  Stream<QuerySnapshot> chatStream(String uidOtherUser) {
    return Firestore.instance
        .collection("chats")
        .where(firebaseUser.uid, isEqualTo: true)
        .where(uidOtherUser, isEqualTo: true)
        .snapshots();
  }

  sendChatMessage(String uidOtherUser, String message) async {
    message = message.trim();
    if (message.isEmpty || message.length > 2000) return;

    List<DocumentSnapshot> documentSnapshots = (await Firestore.instance
            .collection("chats")
            .where(firebaseUser.uid, isEqualTo: true)
            .where(uidOtherUser, isEqualTo: true)
            .getDocuments())
        .documents;
    if (documentSnapshots.isEmpty) {
      Firestore.instance.collection("chats").document().setData({
        firebaseUser.uid: true,
        uidOtherUser: true,
        "messages": [
          {firebaseUser.uid.substring(0, 6): true, "m": message}
        ],
        "lastMessage": DateTime.now()
      });
    } else {
      List<dynamic> messagesList = documentSnapshots.first.data["messages"];
      messagesList.add({firebaseUser.uid.substring(0, 6): true, "m": message});
      Firestore.instance
          .collection("chats")
          .document(documentSnapshots.first.documentID)
          .updateData({
        firebaseUser.uid: true,
        uidOtherUser: true,
        "messages": messagesList,
        "lastMessage": DateTime.now()
      });
    }
  }
}
