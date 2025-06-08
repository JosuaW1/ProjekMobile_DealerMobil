import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/database_helper.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await DatabaseHelper.instance.getAllUsers();
    } catch (e) {
      print('Error fetching users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUser(User user) async {
    try {
      int result = await DatabaseHelper.instance.updateUser(user);
      if (result > 0) {
        await fetchUsers(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      int result = await DatabaseHelper.instance.deleteUser(userId);
      if (result > 0) {
        await fetchUsers(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUserRole(int userId, String role) async {
    try {
      int result = await DatabaseHelper.instance.updateUserRole(userId, role);
      if (result > 0) {
        await fetchUsers(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  List<User> getUsersByRole(String role) {
    return _users.where((user) => user.role == role).toList();
  }

  User? getUserById(int id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }
}
