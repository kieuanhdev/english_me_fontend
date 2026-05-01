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

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final idToken = await _authService.signInWithGoogle();
      if (idToken == null) return;
      await _syncWithBackend(idToken);
    } catch (_) {
      Get.snackbar('Lỗi', 'Đăng nhập thất bại. Vui lòng thử lại.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _syncWithBackend(String idToken) async {
    final result = await _repository.syncUserWithBackend(idToken);
    user.value = result;

    if (!result.isOnboarded) {
      Get.offAllNamed('/placement-test');
    } else {
      Get.offAllNamed('/dashboard');
    }
  }
}
