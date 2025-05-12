import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProviders with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _user;
  String? _errorMessage;

  User? get user => _user;
  String? get errorMessage => _errorMessage;

  AuthProviders() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      _errorMessage = null;
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _user = userCredential.user;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi không mong muốn';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _errorMessage = null;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi không mong muốn';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _errorMessage = null;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _errorMessage = 'Đăng nhập bằng Google bị hủy';
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      // Lưu thông tin người dùng vào Firestore nếu chưa tồn tại
      final userDoc = await _firestore.collection('users').doc(_user?.uid).get();
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(_user?.uid).set({
          'name': _user?.displayName ?? 'Người dùng Google',
          'email': _user?.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi đăng nhập bằng Google: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      _errorMessage = null;
      // Đăng xuất Google (nếu có thể)
      try {
        await _googleSignIn.signOut();
        print('Google Sign-In đăng xuất thành công');
      } catch (e) {
        print('Lỗi đăng xuất Google: $e');
        _errorMessage = 'Không thể đăng xuất Google, nhưng Firebase đã đăng xuất';
      }
      // Đăng xuất Firebase
      await _auth.signOut();
      _user = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi đăng xuất Firebase: $e';
      notifyListeners();
      return false;
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email đã được sử dụng.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu.';
      case 'user-not-found':
      case 'wrong-password':
        return 'Email hoặc mật khẩu không đúng.';
      case 'account-exists-with-different-credential':
        return 'Tài khoản đã tồn tại với phương thức đăng nhập khác.';
      case 'popup-closed-by-user':
        return 'Đăng nhập bằng Google bị hủy.';
      default:
        return 'Đăng nhập thất bại. Vui lòng thử lại.';
    }
  }
}