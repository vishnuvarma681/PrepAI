import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// StreamProvider for authentication state changes
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

// AsyncNotifier to manage interactive Auth loading states (Riverpod 3 replacement for StateNotifier<AsyncValue<T>>)
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, UserEntity?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<UserEntity?> {
  late final AuthRepository _repository;

  @override
  Future<UserEntity?> build() async {
    _repository = ref.watch(authRepositoryProvider);
    return await _repository.getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signInWithEmailAndPassword(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> register(String email, String password, String displayName) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signUpWithEmailAndPassword(email, password, displayName);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
