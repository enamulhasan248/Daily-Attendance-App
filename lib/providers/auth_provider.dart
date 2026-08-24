/// Auth provider — manages login state via SharedPreferences + SQLite.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

const _userIdKey = 'logged_in_user_id';

/// Holds the currently logged-in user, or null if not logged in.
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null);

  /// Check SharedPreferences for a saved user ID and auto-login.
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);
    if (userId != null) {
      final user = await DatabaseHelper.instance.getUserById(userId);
      if (user != null) {
        state = user;
      } else {
        // Stale ID — clear it.
        await prefs.remove(_userIdKey);
      }
    }
  }

  /// Login with name and employee ID.
  Future<void> login(String name, String employeeId) async {
    final user =
        await DatabaseHelper.instance.insertOrGetUser(name, employeeId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, user.id!);
    state = user;
  }

  /// Logout — clear saved user ID.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    state = null;
  }
}
