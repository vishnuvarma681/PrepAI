import 'dart:async';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  // In-memory authentication state tracker for simulation
  UserEntity? _currentUser;
  final StreamController<UserEntity?> _authStreamController = StreamController<UserEntity?>.broadcast();

  AuthRepositoryImpl() {
    // Initial state: start as guest or signed out
    _currentUser = null;
    _authStreamController.add(null);
  }

  @override
  Stream<UserEntity?> authStateChanges() => _authStreamController.stream;

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network latency

    if (email.contains('@') && password.length >= 6) {
      final user = UserModel(
        uid: 'mock_uid_${email.hashCode}',
        email: email,
        displayName: email.split('@')[0],
      );
      _currentUser = user;
      _authStreamController.add(user);
      return user;
    } else {
      throw Exception('Invalid email or password (min 6 characters required).');
    }
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword(String email, String password, String displayName) async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulate network latency

    if (!email.contains('@')) {
      throw Exception('Please enter a valid email address.');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    final user = UserModel(
      uid: 'mock_uid_${email.hashCode}',
      email: email,
      displayName: displayName.isNotEmpty ? displayName : email.split('@')[0],
    );
    _currentUser = user;
    _authStreamController.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = null;
    _authStreamController.add(null);
  }
}

/*
========================================================================
FIREBASE AUTHENTICATION PRODUCTION CODE TEMPLATE
========================================================================
To swap to Firebase Auth, add firebase_core & firebase_auth to pubspec.yaml, 
initialize Firebase, and replace the implementation with this:

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserEntity? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _mapFirebaseUser(_firebaseAuth.currentUser);
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword(String email, String password) async {
    final credentials = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _mapFirebaseUser(credentials.user)!;
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword(String email, String password, String displayName) async {
    final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credentials.user?.updateDisplayName(displayName);
    return _mapFirebaseUser(_firebaseAuth.currentUser)!;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
========================================================================
*/
