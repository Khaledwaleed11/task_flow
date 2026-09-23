import 'package:firebase_auth/firebase_auth.dart';

import 'current_user_provider.dart';

class FirebaseCurrentUserProvider
    implements CurrentUserProvider {
  final FirebaseAuth firebaseAuth;

  FirebaseCurrentUserProvider({
    required this.firebaseAuth,
  });

  @override
  String? get currentUserId {
    return firebaseAuth.currentUser?.uid;
  }
}