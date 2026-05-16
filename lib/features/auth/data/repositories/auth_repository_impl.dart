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

  /// Fetch user data from Firestore, falling back to Firebase Auth data
  Future<UserEntity> _getUserWithFirestoreData(User firebaseUser) async {
    final baseUser = UserModel.fromFirebaseUser(firebaseUser);
    try {
      final doc = await firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (_) {
      // If Firestore read fails, just use basic user data
    }
    return baseUser;
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _getUserWithFirestoreData(user);
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
  Future<void> markSetupComplete(String userId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .update({'isSetupComplete': true});
    } catch (e) {
      debugPrint('markSetupComplete failed: $e');
    }
  }

  @override
  Future<UserEntity?> getUserById(String userId) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;
      return _getUserWithFirestoreData(user);
    } catch (e) {
      debugPrint('getUserById failed: $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }
}
