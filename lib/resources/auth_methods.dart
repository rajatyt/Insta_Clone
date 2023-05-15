import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:insta_clone/models/user.dart' as model;
import 'package:insta_clone/resources/storage_methods.dart';
import 'package:matcher/matcher.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestrore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap = await _firestrore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap
        // followers: (snap.data() as Map<String,dynamic>)['follower']
        );
  }

  //signup user
  Future<String> signupUser({
    required String email,
    required String pass,
    required String userName,
    required String bio,
    required Uint8List file,
  }) async {
    String res = 'some error occured';
    try {
      if (email.isNotEmpty ||
          pass.isNotEmpty ||
          userName.isNotEmpty ||
          bio.isNotEmpty) {
        //register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: pass);
        print(cred.user!.uid);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        // add user to pur database
        // _firestrore.collection('users').doc(cred.user!.uid).set({
        //   'username': userName,
        //   'uid': cred.user!.uid,
        //   'email': email,
        //   'bio': bio,
        //   'followers': [],
        //   'following': [],
        // });

        //

        model.User user = model.User(
          username: userName,
          uid: cred.user!.uid,
          email: email,
          bio: bio,
          followers: [],
          photoUrl: photoUrl,
          following: [],
        );
        await _firestrore.collection('users').doc(cred.user!.uid).set(
              user.toJson(),
            );
        res = 'success';
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = "the email is badly formatted";
      } else if (err.code == 'weak-password') {
        res = 'Your password should be atleast 8 character';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //Logging in user
  Future<String> loginUser({
    required String email,
    required String pass,
  }) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty || pass.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: pass);
        res = 'success';
      } else {
        res = 'please enter all the fields';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = 'Please check username/Password';
      } else if (e.code == 'wrong-password') {
        res = 'Please check username/Password';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
