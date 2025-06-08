import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/database_helper.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    if (userId != null) {
      // Load user data from database
      List<User> users = await DatabaseHelper.instance.getAllUsers();
      _currentUser = users.firstWhere((user) => user.id == userId);
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      User? user = await DatabaseHelper.instance.getUser(email, password);
      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;

        // Save session
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', user.id!);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(User user) async {
    try {
      await DatabaseHelper.instance.insertUser(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');

    notifyListeners();
  }

  Future<bool> updateProfile(User updatedUser) async {
    try {
      await DatabaseHelper.instance.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      if (_currentUser != null) {
        await DatabaseHelper.instance.deleteUser(_currentUser!.id!);
        await logout();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
