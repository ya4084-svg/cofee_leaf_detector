import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  final String name;
  final String email;
  final String farmLocation;

  AppUser({
    required this.name,
    required this.email,
    required this.farmLocation,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'farmLocation': farmLocation,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    farmLocation: json['farmLocation'] ?? '',
  );
}

class AuthService {
  static const String _userKey = 'coffee_app_current_user';
  static const String _loggedInKey = 'coffee_app_is_logged_in';

  static AppUser? currentUser;
  static bool isLoggedIn = false;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
    final rawUser = prefs.getString(_userKey);
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        currentUser = AppUser.fromJson(jsonDecode(rawUser));
      } catch (e) {
        currentUser = null;
      }
    }
  }

  static Future<bool> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.length < 4) return false;

    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString('user_acc_${email.trim().toLowerCase()}');
    
    AppUser user;
    if (rawUser != null) {
      user = AppUser.fromJson(jsonDecode(rawUser));
    } else {
      final derivedName = email.split('@').first;
      user = AppUser(
        name: derivedName.isNotEmpty ? derivedName : 'Coffee Farmer',
        email: email.trim(),
        farmLocation: 'ኢትዮጵያ (Ethiopia)',
      );
      await prefs.setString('user_acc_${email.trim().toLowerCase()}', jsonEncode(user.toJson()));
    }

    currentUser = user;
    isLoggedIn = true;
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    return true;
  }

  static Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String farmLocation,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.length < 4) {
      return false;
    }

    final user = AppUser(
      name: name.trim(),
      email: email.trim(),
      farmLocation: farmLocation.trim().isNotEmpty ? farmLocation.trim() : 'ኢትዮጵያ',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_acc_${email.trim().toLowerCase()}', jsonEncode(user.toJson()));
    
    currentUser = user;
    isLoggedIn = true;
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    return true;
  }

  static Future<void> logout() async {
    currentUser = null;
    isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
    await prefs.remove(_userKey);
  }
}
