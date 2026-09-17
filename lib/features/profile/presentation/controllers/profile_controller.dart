import 'package:flutter/material.dart';
import '../../domain/models/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/profile_api_repository.dart';

enum ProfileStatus { initial, loading, loaded, updating, error }

class ProfileController extends ChangeNotifier {
  final ProfileRepository _repository = ProfileApiRepository();

  Profile? _profile;
  ProfileStatus _status = ProfileStatus.initial;
  String? _error;

  Profile? get profile => _profile;
  ProfileStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == ProfileStatus.loading;
  bool get isUpdating => _status == ProfileStatus.updating;

  Future<void> loadProfile(String userId) async {
    _status = ProfileStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfile(userId);
      _status = ProfileStatus.loaded;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = ProfileStatus.error;
    }
    notifyListeners();
  }

  Future<bool> updateProfile(Profile updated) async {
    _status = ProfileStatus.updating;
    _error = null;
    notifyListeners();

    try {
      _profile = await _repository.updateProfile(updated);
      _status = ProfileStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = ProfileStatus.error;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
