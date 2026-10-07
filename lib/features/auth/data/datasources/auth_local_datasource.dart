import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/constants.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage? secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSource({
    this.secureStorage,
    required this.sharedPreferences,
  });

  // Token Management — uses SecureStorage on native, SharedPreferences on web
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (secureStorage != null) {
      await secureStorage!.write(key: AppConstants.keyAccessToken, value: accessToken);
      await secureStorage!.write(key: AppConstants.keyRefreshToken, value: refreshToken);
    } else {
      await sharedPreferences.setString(AppConstants.keyAccessToken, accessToken);
      await sharedPreferences.setString(AppConstants.keyRefreshToken, refreshToken);
    }
  }

  Future<String?> getAccessToken() async {
    if (secureStorage != null) {
      return await secureStorage!.read(key: AppConstants.keyAccessToken);
    }
    return sharedPreferences.getString(AppConstants.keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    if (secureStorage != null) {
      return await secureStorage!.read(key: AppConstants.keyRefreshToken);
    }
    return sharedPreferences.getString(AppConstants.keyRefreshToken);
  }

  Future<void> clearTokens() async {
    if (secureStorage != null) {
      await secureStorage!.delete(key: AppConstants.keyAccessToken);
      await secureStorage!.delete(key: AppConstants.keyRefreshToken);
    } else {
      await sharedPreferences.remove(AppConstants.keyAccessToken);
      await sharedPreferences.remove(AppConstants.keyRefreshToken);
    }
  }

  // User Management
  Future<void> saveUser(User user) async {
    await sharedPreferences.setString(AppConstants.keyUserId, user.id);
    await sharedPreferences.setString(AppConstants.keyUserEmail, user.email);
    await sharedPreferences.setString(AppConstants.keyUserName, user.name);
    await sharedPreferences.setString(AppConstants.keyLocale, user.locale);
  }

  Future<User?> getCachedUser() async {
    final userId = sharedPreferences.getString(AppConstants.keyUserId);
    final email = sharedPreferences.getString(AppConstants.keyUserEmail);
    final name = sharedPreferences.getString(AppConstants.keyUserName);
    final locale = sharedPreferences.getString(AppConstants.keyLocale);

    if (userId != null && email != null && name != null && locale != null) {
      return UserModel(
        id: userId,
        email: email,
        name: name,
        locale: locale,
      );
    }

    return null;
  }

  Future<void> clearUser() async {
    await sharedPreferences.remove(AppConstants.keyUserId);
    await sharedPreferences.remove(AppConstants.keyUserEmail);
    await sharedPreferences.remove(AppConstants.keyUserName);
    await sharedPreferences.remove(AppConstants.keyLocale);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  Future<void> clearAll() async {
    await clearTokens();
    await clearUser();
  }
}
