import 'package:firebase_auth/firebase_auth.dart';
import 'package:englishme/core/services/auth_service.dart';
import 'package:englishme/data/models/user_model.dart';
import 'package:englishme/data/repositories/auth_repository.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthRepository _repository;
  final AuthService _authService;

  AuthController(this._repository, this._authService);

  final isLoading = false.obs;
  final Rxn<UserModel> user = Rxn<UserModel>();

  // ── Google ──────────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final idToken = await _authService.signInWithGoogle();
      if (idToken == null) return;
      await _navigateAfterSync(await _repository.syncUserWithBackend(idToken));
    } on FirebaseAuthException catch (e) {
      _showFirebaseError(e);
    } catch (_) {
      _showError('Đăng nhập thất bại. Vui lòng thử lại.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Email login ─────────────────────────────────────────────────────────

  Future<void> signInWithEmail(String email, String password) async {
    final error = _validateEmailPassword(email, password);
    if (error != null) {
      _showError(error);
      return;
    }
    try {
      isLoading.value = true;
      final idToken = await _authService.signInWithEmail(email, password);
      if (idToken == null) return;
      await _navigateAfterSync(await _repository.syncUserWithBackend(idToken));
    } on FirebaseAuthException catch (e) {
      _showFirebaseError(e);
    } catch (_) {
      _showError('Đăng nhập thất bại. Vui lòng thử lại.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Email register ──────────────────────────────────────────────────────

  Future<void> signUpWithEmail(
    String fullName,
    String email,
    String password,
    String confirmPassword,
  ) async {
    final error = _validateRegister(fullName, email, password, confirmPassword);
    if (error != null) {
      _showError(error);
      return;
    }
    try {
      isLoading.value = true;
      final idToken = await _authService.signUpWithEmail(email, password);
      if (idToken == null) return;
      await _navigateAfterSync(await _repository.syncUserWithBackend(idToken));
    } on FirebaseAuthException catch (e) {
      _showFirebaseError(e);
    } catch (_) {
      _showError('Đăng ký thất bại. Vui lòng thử lại.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  Future<void> _navigateAfterSync(UserModel result) async {
    user.value = result;
    if (!result.isOnboarded) {
      Get.offAllNamed('/placement-test');
    } else {
      Get.offAllNamed('/home');
    }
  }

  String? _validateEmailPassword(String email, String password) {
    if (email.trim().isEmpty) return 'Vui lòng nhập email.';
    if (!GetUtils.isEmail(email.trim())) return 'Email không hợp lệ.';
    if (password.isEmpty) return 'Vui lòng nhập mật khẩu.';
    if (password.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự.';
    return null;
  }

  String? _validateRegister(
    String fullName,
    String email,
    String password,
    String confirmPassword,
  ) {
    if (fullName.trim().isEmpty) return 'Vui lòng nhập họ và tên.';
    final emailError = _validateEmailPassword(email, password);
    if (emailError != null) return emailError;
    if (password != confirmPassword) return 'Mật khẩu xác nhận không khớp.';
    return null;
  }

  void _showFirebaseError(FirebaseAuthException e) {
    final message = switch (e.code) {
      'user-not-found' => 'Tài khoản không tồn tại.',
      'wrong-password' => 'Mật khẩu không đúng.',
      'email-already-in-use' => 'Email đã được sử dụng.',
      'invalid-email' => 'Email không hợp lệ.',
      'weak-password' => 'Mật khẩu quá yếu (tối thiểu 6 ký tự).',
      'too-many-requests' => 'Quá nhiều yêu cầu. Vui lòng thử lại sau.',
      'invalid-credential' => 'Email hoặc mật khẩu không đúng.',
      _ => 'Đã xảy ra lỗi. Vui lòng thử lại.',
    };
    _showError(message);
  }

  void _showError(String message) {
    Get.snackbar('Lỗi', message, snackPosition: SnackPosition.BOTTOM);
  }
}
