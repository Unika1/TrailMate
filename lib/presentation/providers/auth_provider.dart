import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/api_service.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String token;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });
}

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AuthUser? _user;

  AuthUser? get user => _user;
  bool get isLoggedIn => _user != null;
  String get userName => _user?.name ?? 'Guest User';
  String? get token => _user?.token;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final name = prefs.getString('userName');
    final email = prefs.getString('userEmail');
    final id = prefs.getString('userId');

    if (token != null && name != null && email != null && id != null) {
      _user = AuthUser(id: id, name: name, email: email, token: token);
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    final data = await _apiService.login(email, password);
    await _saveUser(data);
  }

  Future<void> signup(String name, String email, String password) async {
    final data = await _apiService.signup(name, email, password);
    await _saveUser(data);
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userId');
    notifyListeners();
  }

  Future<void> _saveUser(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;

    _user = AuthUser(
      id: user['_id'] ?? user['id'] ?? '',
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      token: token,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userName', _user!.name);
    await prefs.setString('userEmail', _user!.email);
    await prefs.setString('userId', _user!.id);

    notifyListeners();
  }
}

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});
