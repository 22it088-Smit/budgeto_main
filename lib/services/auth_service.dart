import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;
  bool _isLoading = false;
  String? _error;
  String? _email;
  String? _displayName;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get email => _email;
  String? get displayName => _displayName;
  bool get isAuthenticated => _isLoggedIn;
  bool get isEmailVerified => true; // Since we're not using Firebase, we'll assume email is verified

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simulate login delay
    await Future.delayed(const Duration(seconds: 1));
    
    // For demo purposes, accept any email/password
    _isLoggedIn = true;
    _userId = 'demo_user_${DateTime.now().millisecondsSinceEpoch}';
    _email = email;
    _displayName = email.split('@')[0];
    
    // Save login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', _userId!);
    await prefs.setString('email', _email!);
    await prefs.setString('displayName', _displayName!);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simulate registration delay
    await Future.delayed(const Duration(seconds: 1));
    
    _isLoggedIn = true;
    _userId = 'demo_user_${DateTime.now().millisecondsSinceEpoch}';
    _email = email;
    _displayName = name;
    
    // Save registration state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', _userId!);
    await prefs.setString('email', _email!);
    await prefs.setString('displayName', _displayName!);
    
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userId = null;
    _email = null;
    _displayName = null;
    
    // Clear login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('displayName');
    
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userId = prefs.getString('userId');
    _email = prefs.getString('email');
    _displayName = prefs.getString('displayName');
    notifyListeners();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simulate password reset delay
    await Future.delayed(const Duration(seconds: 1));
    
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> sendEmailVerification() async {
    // Since we're not using Firebase, we'll just return true
    return true;
  }

  Future<bool> checkEmailVerification() async {
    // Since we're not using Firebase, we'll just return true
    return true;
  }
}