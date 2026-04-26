import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/data/repositories/user_firestore_repository.dart';
import 'global_error_provider.dart';

part 'auth_provider.g.dart';

final devBypassAuthProvider = StateProvider<bool>((ref) => false);

@riverpod
class AuthState extends _$AuthState {
  @override
  Future<UserModel?> build() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return null;
    try {
      return await ref
          .read(userFirestoreRepositoryProvider)
          .getUser(firebaseUser.uid);
    } catch (e) {
      ref.pushError(e);
      return null;
    }
  }

  Future<void> loginWithFirebaseUser(User firebaseUser) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(userFirestoreRepositoryProvider)
          .findOrCreate(firebaseUser),
    );
  }

  Future<void> updateProfile({
    String? username,
    List<String>? sports,
    String? level,
    String? avatar,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await ref.read(userFirestoreRepositoryProvider).updateProfile(
            uid,
            username: username,
            sports: sports,
            level: level,
            avatar: avatar,
          );
      state = AsyncData(
        await ref.read(userFirestoreRepositoryProvider).getUser(uid),
      );
    } catch (e) {
      ref.pushError(e);
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    state = const AsyncData(null);
  }
}
