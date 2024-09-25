import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone_flutter/models/user.dart' as model;
import 'package:instagram_clone_flutter/resources/storage_methods.dart';



class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap = await _firestore.collection('users').doc(currentUser.uid).get();
    
    return model.User.fromSnap(snap);
}

  // sign up user
  Future<String> signupUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "some error occurred";
    try {
      if(email.isNotEmpty && username.isNotEmpty && password.isNotEmpty){
        if(bio.isEmpty) bio = "";
        //  register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        print(cred.user!.uid);

        String photoUrl  = await StorageMethods().uploadImageToStorage('profilePics', file, false);

        // add user to user databse
        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          email: email,
          bio: bio,
          followers: [],
          following: [],
        );

        // save data in database
        await _firestore
            .collection("users")
            .doc(cred.user!.uid)
            .set(user.toJson());
        res = "success";
      } else {
        if(email.isEmpty && username.isEmpty && password.isEmpty && file != null){
          res = "Please enter all the fields";
        } else if (email.isEmpty){
          res = 'Enter Email';
        } else if(password.isEmpty) {
          res = 'Enter Password';
        } else if(username.isEmpty) {
          res = 'Enter username';
        } else {
          res = 'Error';
        }
      }
    } catch(err) {
      res = 'Invalid information';
    }
    return res;
  }

  // login user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res;
    try{
        if(email.isNotEmpty && password.isNotEmpty){
          await _auth.signInWithEmailAndPassword(email: email, password: password);
          res = 'success';
        } else {
          if(email.isEmpty && password.isEmpty)
            res = "Please enter all the fields";
          else if(email.isEmpty)
            res = "Enter email";
          else if(password.isEmpty)
            res = "Enter password";
          else
            res = 'Error';
        }
    } catch(err) {
        res  = 'Please try again !';
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

}