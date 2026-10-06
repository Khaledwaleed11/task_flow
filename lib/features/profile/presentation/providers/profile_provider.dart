import 'package:flutter/foundation.dart';

import '../../../../features/auth/domain/entities/user_entity.dart';
import '../../domain/usecases/update_profile_image.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  failure,
}

class ProfileProvider extends ChangeNotifier {
  final UpdateProfileImage updateProfileImageUseCase;

  ProfileProvider({
    required this.updateProfileImageUseCase,
  });

  ProfileStatus _status = ProfileStatus.initial;
  UserEntity? _user;
  String? _errorMessage;

  ProfileStatus get status => _status;
  UserEntity? get user => _user;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == ProfileStatus.loading;

  Future<bool> updateProfileImage({
    required String userId,
    required String filePath,
  }) async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await updateProfileImageUseCase(
      UpdateProfileImageParams(
        userId: userId,
        filePath: filePath,
      ),
    );

    return result.fold(
          (failure) {
        _status = ProfileStatus.failure;
        _errorMessage = failure.message;
        notifyListeners();

        return false;
      },
          (user) {
        _user = user;
        _status = ProfileStatus.success;
        _errorMessage = null;
        notifyListeners();

        return true;
      },
    );
  }

  void setUser(UserEntity user) {
    _user = user;
    _status = ProfileStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}