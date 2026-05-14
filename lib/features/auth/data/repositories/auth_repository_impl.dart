import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/auth/data/models/user_model.dart';
import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.firestore,
  });

  @override
  Stream<UserEntity?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }

  // @override
  // Future<UserEntity> signInWithGoogle() async {
  //   final googleUser = await googleSignIn.authenticate();

  //   final googleAuth = googleUser.authentication;

  //   final credential = GoogleAuthProvider.credential(
  //     idToken: googleAuth.idToken,
  //   );

  //   final userCredential = await firebaseAuth.signInWithCredential(credential);
  //   final user = userCredential.user!;
  //   final userModel = UserModel.fromFirebaseUser(user);

  //   // حفظ بيانات المستخدم في Firestore
  //   await firestore
  //       .collection('users')
  //       .doc(user.uid)
  //       .set(
  //         userModel.toMap(),
  //         SetOptions(merge: true), // merge حتى لا نحذف بيانات موجودة
  //       );

  //   return userModel;
  // }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final googleUser = await googleSignIn.authenticate();

    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user!;
    final userModel = UserModel.fromFirebaseUser(user);

    // ✅ لا نوقف العملية لو فشل الحفظ
    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore save failed: $e');
    }

    return userModel;
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return UserModel.fromFirebaseUser(userCredential.user!);
  }

  @override
  Future<UserEntity> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user!;
    await user.updateDisplayName(displayName);
    await user.reload();

    final userModel = UserModel.fromFirebaseUser(
      firebaseAuth.currentUser ?? user,
    );
    await firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap(), SetOptions(merge: true));

    return userModel;
  }

  @override
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }
}
