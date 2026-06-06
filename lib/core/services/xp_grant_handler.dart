import 'package:englishme/core/services/sound_service.dart';
import 'package:englishme/core/utils/app_notify.dart';
import 'package:englishme/core/widgets/daily_goal_celebration.dart';
import 'package:englishme/modules/home/controllers/home_controller.dart';
import 'package:englishme/modules/learn/models/learning_models.dart' show XpBonus;
import 'package:englishme/modules/profile/controllers/profile_controller.dart';
import 'package:englishme/modules/progress/controllers/progress_controller.dart';
import 'package:get/get.dart';

/// Logic chung xử lý kết quả cộng XP từ 4 endpoint (learning/test/exercise/review).
/// Spec §9.5:
///  - FE set thẳng `totalXp` vào ProfileController (không refetch /profile).
///  - Hiển thị toast/snackbar phụ cho từng bonus.
///  - Trigger refresh ProgressController (chart/streak) + HomeController
///    (XP hôm nay / streak / ngày học) khi xpEarned > 0.
class XpGrantHandler {
  XpGrantHandler._();

  /// Áp dụng kết quả cộng XP vào state app.
  ///
  /// - [totalXp] / [streakUpdated]: cập nhật ProfileController.
  /// - [bonuses]: hiển thị từng snackbar phụ (nếu có).
  /// - Khi [xpEarned] > 0: refresh ProgressController (chart/streak) và
  ///   HomeController (dashboard) ngầm, để các màn này tự cập nhật khi user
  ///   quay về mà KHÔNG cần kéo refresh tay. Các màn học thường push đè lên
  ///   shell (không đổi tab) nên listener đổi-tab của Home không bắn — đây là
  ///   nơi duy nhất mọi luồng cộng XP đi qua, nên đẩy refresh từ đây.
  /// - [refreshScreens]: refresh ngầm Home + Progress (mặc định true). Đặt false
  ///   cho luồng grant lặp nhiều lần trong 1 phiên (vd ôn flashcard cộng XP từng
  ///   thẻ) để tránh spam request; luồng đó tự gọi [refreshScreensOnce] khi kết
  ///   thúc phiên.
  static void apply({
    required int totalXp,
    int xpEarned = 0,
    bool streakUpdated = false,
    bool leveledUp = false,
    List<XpBonus> bonuses = const [],
    bool refreshScreens = true,
    bool playCompletionSound = true,
  }) {
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().applyXpGrant(
        totalXp: totalXp,
        streakUpdated: streakUpdated,
      );
    }
    if (xpEarned > 0 && refreshScreens) {
      refreshScreensOnce();
    }

    final hasDailyGoal =
        bonuses.any((b) => b.type == 'daily_goal_bonus' && b.amount > 0);

    // Hiệu ứng âm thanh "to" nhất thắng: lên cấp > đạt mục tiêu ngày > hoàn
    // thành thường. Chỉ phát 1 lần, tránh chồng nhiều tiếng cùng lúc.
    // [playCompletionSound] = false cho luồng grant lặp (vd ôn từng flashcard).
    if (playCompletionSound) {
      if (leveledUp) {
        SoundService.to.play(AppSound.levelUp);
      } else if (hasDailyGoal) {
        SoundService.to.play(AppSound.dailyGoal);
      } else if (xpEarned > 0) {
        SoundService.to.play(AppSound.complete);
      }
    }

    for (final bonus in bonuses) {
      if (bonus.amount <= 0) continue;
      // Đạt mục tiêu ngày → dialog chúc mừng nổi bật thay vì snackbar nhỏ.
      if (bonus.type == 'daily_goal_bonus') {
        DailyGoalCelebration.show(bonusXp: bonus.amount, label: bonus.label);
      } else {
        _showBonusToast(bonus);
      }
    }
  }

  /// Refresh ngầm các màn hiển thị XP (Home dashboard + Progress) nếu chúng đang
  /// sống trong bộ nhớ. Dùng khi rời màn học để số liệu cập nhật mà không cần
  /// kéo refresh tay.
  static void refreshScreensOnce() {
    if (Get.isRegistered<ProgressController>()) {
      Get.find<ProgressController>().loadProgress();
    }
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadDashboard(silent: true);
    }
  }

  static void _showBonusToast(XpBonus bonus) {
    final label = bonus.label.isNotEmpty
        ? bonus.label
        : 'Bonus +${bonus.amount} XP';
    AppNotify.success(label, message: '+${bonus.amount} XP');
  }
}
