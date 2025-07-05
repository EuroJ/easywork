import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthProviderOffline extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Demo users
  final List<Map<String, String>> _demoUsers = [
    {
      'email': 'admin@easywork.com',
      'password': 'admin123',
      'firstName': 'ທ້າວ',
      'lastName': 'ແອດມິນ',
      'role': 'admin',
      'uid': 'admin-offline',
    },
    {
      'email': 'demo@easywork.com',
      'password': 'demo123',
      'firstName': 'Demo',
      'lastName': 'User',
      'role': 'employee',
      'uid': 'demo-offline',
    },
    {
      'email': 'john@easywork.com',
      'password': 'user123',
      'firstName': 'John',
      'lastName': 'Doe',
      'role': 'employee',
      'uid': 'john-offline',
    },
    {
      'email': 'mary@easywork.com',
      'password': 'user123',
      'firstName': 'Mary',
      'lastName': 'Smith',
      'role': 'employee',
      'uid': 'mary-offline',
    },
  ];

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      print('🔐 Attempting login: $email');

      // จำลองการ login
      await Future.delayed(const Duration(seconds: 1));

      final user = _demoUsers.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => {},
      );

      if (user.isNotEmpty) {
        _currentUser = UserModel(
          uid: user['uid']!,
          email: user['email']!,
          firstName: user['firstName']!,
          lastName: user['lastName']!,
          role: user['role']!,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        print('✅ Login successful: ${_currentUser!.fullName} (${_currentUser!.role})');
        notifyListeners();
        return true;
      } else {
        _setError('ອີເມລ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ');
        print('❌ Login failed: Invalid credentials');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      print('❌ Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password, String firstName, String lastName) async {
    try {
      _setLoading(true);
      _clearError();

      print('📝 Attempting registration: $email');

      // จำลองการ register
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = UserModel(
        uid: 'user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: 'employee',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      print('✅ Registration successful: ${_currentUser!.fullName}');
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      print('❌ Registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      print('🚪 Signing out user: ${_currentUser?.fullName}');
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      _currentUser = null;
      _clearError();
      
      print('✅ Sign out successful');
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      print('❌ Sign out error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Auto login สำหรับ demo
  Future<void> autoLogin() async {
    try {
      _setLoading(true);
      print('🔄 Checking for auto login...');
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // ในโหมด demo ไม่มี auto login
      print('ℹ️ No auto login available in demo mode');
    } catch (e) {
      print('❌ Auto login error: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // รีเซ็ตข้อมูล
  void reset() {
    print('🔄 Resetting AuthProvider...');
    _currentUser = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}