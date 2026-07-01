import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:englishme/core/network/api_exception.dart';
import 'package:englishme/core/services/auth_service.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/auth/models/user_model.dart';
import 'package:englishme/modules/auth/repositories/auth_repository.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/core/utils/app_notify.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthRepository _repository;
  final AuthService _authService;

  AuthController(this._repository, this._authService);

  /// Loading cho hành động email (login/register) — nút email tự xoay.
  final isLoading = false.obs;

  /// Loading RIÊNG cho nút Google — tách khỏi [isLoading] để chỉ nút Google
  /// xoay khi bấm Google, nút email không bị ảnh hưởng (và ngược lại).
  final isGoogleLoading = false.obs;

  final Rxn<UserModel> user = Rxn<UserModel>();

  /// Khi MỘT hành động đang chạy, các nút còn lại phải bị khoá (disable) nhưng
  /// KHÔNG hiện spinner. Helper gom điều kiện "đang có việc gì đó chạy".
  bool get isBusy => isLoading.value || isGoogleLoading.value;

  // ── Google ──────────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    try {
      isGoogleLoading.value = true;
      final idToken = await _authService.signInWithGoogle();
      if (idToken == null) return;
      await _navigateAfterSync(await _repository.syncUserWithBackend(idToken));
    } on FirebaseAuthException catch (e) {
      _showFirebaseError(e);
    } on DioException catch (e) {
      _showApiError(e, fallback: T.authLoginFailed.tr);
    } finally {
      isGoogleLoading.value = false;
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
    } on DioException catch (e) {
      _showApiError(e, fallback: T.authLoginFailed.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Email register ──────────────────────────────────────────────────────

  Future<void> signUpWithEmail(
    String fullName,
    String email,
    String password,
    String confirmPassword, {
    bool agreedToTerms = false,
  }) async {
    final error = _validateRegister(
      fullName,
      email,
      password,
      confirmPassword,
      agreedToTerms,
    );
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
    } on DioException catch (e) {
      _showApiError(e, fallback: T.authRegisterFailed.tr);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Auto-login ───────────────────────────────────────────────────────────

  /// Trả về tên route cần navigate tới, hoặc null nếu không có session.
  Future<String?> tryAutoLogin() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      final idToken = await currentUser.getIdToken();
      if (idToken == null) return null;

      final result = await _repository.syncUserWithBackend(idToken);
      user.value = result;
      return result.isOnboarded ? AppRoutes.shell : AppRoutes.placementTest;
    } catch (_) {
      await FirebaseAuth.instance.signOut();
      return null;
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  Future<void> _navigateAfterSync(UserModel result) async {
    user.value = result;
    if (!result.isOnboarded) {
      Get.offAllNamed(AppRoutes.placementTest);
    } else {
      Get.offAllNamed(AppRoutes.shell);
    }
  }

  String? _validateEmailPassword(String email, String password) {
    if (email.trim().isEmpty) return T.authValidateEmailEmpty.tr;
    if (!GetUtils.isEmail(email.trim())) return T.authValidateEmailInvalid.tr;
    if (password.isEmpty) return T.authValidatePasswordEmpty.tr;
    if (password.length < 6) return T.authValidatePasswordShort.tr;
    return null;
  }

  String? _validateRegister(
    String fullName,
    String email,
    String password,
    String confirmPassword,
    bool agreedToTerms,
  ) {
    if (fullName.trim().isEmpty) return T.authValidateNameEmpty.tr;
    final emailError = _validateEmailPassword(email, password);
    if (emailError != null) return emailError;
    if (password != confirmPassword) return T.authValidatePasswordMismatch.tr;
    if (!agreedToTerms) return T.authValidateTermsRequired.tr;
    return null;
  }

  void _showFirebaseError(FirebaseAuthException e) {
    final message = switch (e.code) {
      'user-not-found' => T.authErrorUserNotFound.tr,
      'wrong-password' => T.authErrorWrongPassword.tr,
      'email-already-in-use' => T.authErrorEmailInUse.tr,
      'invalid-email' => T.authErrorInvalidEmail.tr,
      'weak-password' => T.authErrorWeakPassword.tr,
      'too-many-requests' => T.authErrorTooManyRequests.tr,
      'invalid-credential' => T.authErrorInvalidCredential.tr,
      _ => T.authErrorUnknown.tr,
    };
    _showError(message);
  }

  void _showApiError(DioException e, {required String fallback}) {
    final error = e.error;
    if (error is ApiException && error.message.isNotEmpty) {
      _showError(error.message);
      return;
    }
    _showError(e.message ?? fallback);
  }

  void _showError(String message) {
    AppNotify.error('Lỗi', message: message);
  }
}
