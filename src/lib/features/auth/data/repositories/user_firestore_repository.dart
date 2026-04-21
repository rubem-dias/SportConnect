import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_model.dart';

part 'user_firestore_repository.g.dart';

@riverpod
UserFirestoreRepository userFirestoreRepository(Ref ref) =>
    UserFirestoreRepository(FirebaseFirestore.instance);

class UserFirestoreRepository {
  UserFirestoreRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<UserModel> findOrCreate(User firebaseUser) async {
    final doc = await _users.doc(firebaseUser.uid).get();

    if (doc.exists) {
      return UserModel.fromJson({
        'id': firebaseUser.uid,
        ...doc.data()!,
      });
    }

    final now = DateTime.now();
    final newUser = UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? firebaseUser.email ?? 'Usuário',
      createdAt: now,
      avatar: firebaseUser.photoURL,
    );

    await _users.doc(firebaseUser.uid).set({
      'email': newUser.email,
      'name': newUser.name,
      'createdAt': now.toIso8601String(),
      'avatar': newUser.avatar,
      'sports': [],
      'level': 'beginner',
      'role': 'user',
    });

    return newUser;
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson({'id': uid, ...doc.data()!});
  }

  Future<void> updateProfile(
    String uid, {
    String? username,
    List<String>? sports,
    String? level,
    String? avatar,
  }) async {
    await _users.doc(uid).update({
      if (username != null) 'username': username,
      if (sports != null) 'sports': sports,
      if (level != null) 'level': level,
      if (avatar != null) 'avatar': avatar,
    });
  }
}
