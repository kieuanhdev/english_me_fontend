import 'package:get/get.dart';

import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/notification/models/notification_model.dart';
import 'package:englishme/modules/notification/repositories/notification_repository.dart';

enum NotificationLoadState { idle, loading, success, error }

class NotificationController extends GetxController {
  final NotificationRepository _repo;
  NotificationController(this._repo);

  final items = <AppNotification>[].obs;
  final unreadCount = 0.obs;
  final loadState = NotificationLoadState.idle.obs;

  /// Controller toàn cục (permanent) để chuông — một StatelessWidget nằm sâu
  /// trong cây qua AppMainAppBar ở ~17 màn — truy cập mà không cần binding route.
  /// Mirror [ShellController.ensureRegistered].
  static NotificationController ensureRegistered() {
    if (Get.isRegistered<NotificationController>()) {
      return Get.find<NotificationController>();
    }
    return Get.put(
      NotificationController(NotificationRepository(DioClient.instance)),
      permanent: true,
    );
  }

  @override
  void onInit() {
    super.onInit();
    // Populate badge ngay khi controller được tạo (vào shell sau khi auth).
    refreshUnreadCount();
  }

  /// Tải danh sách + số chưa đọc. [silent] = true: không bật loading toàn sheet.
  Future<void> loadAll({bool silent = false}) async {
    if (!silent) loadState.value = NotificationLoadState.loading;
    try {
      final results = await Future.wait([
        _repo.list(),
        _repo.unreadCount(),
      ]);
      items.value = results[0] as List<AppNotification>;
      unreadCount.value = results[1] as int;
      loadState.value = NotificationLoadState.success;
    } catch (_) {
      if (!silent) loadState.value = NotificationLoadState.error;
    }
  }

  /// Chỉ lấy số chưa đọc — nhẹ, cho badge lúc khởi động.
  Future<void> refreshUnreadCount() async {
    try {
      unreadCount.value = await _repo.unreadCount();
    } catch (_) {
      // Im lặng — badge giữ giá trị cũ, không làm phiền user.
    }
  }

  /// Optimistic: lật cờ local + giảm badge ngay, gọi API nền; lỗi thì tải lại.
  Future<void> markRead(AppNotification n) async {
    if (n.isRead) return;
    final idx = items.indexWhere((e) => e.id == n.id);
    if (idx != -1) {
      items[idx] = items[idx].copyWith(isRead: true);
      if (unreadCount.value > 0) unreadCount.value -= 1;
    }
    try {
      await _repo.markRead(n.id);
    } catch (_) {
      await loadAll(silent: true);
    }
  }

  Future<void> markAllRead() async {
    if (unreadCount.value == 0) return;
    items.value = items.map((e) => e.copyWith(isRead: true)).toList();
    unreadCount.value = 0;
    try {
      await _repo.markAllRead();
    } catch (_) {
      await loadAll(silent: true);
    }
  }

  /// Bấm 1 thông báo: đánh dấu đã đọc + điều hướng nếu có actionRoute.
  void onTapNotification(AppNotification n) {
    markRead(n);
    final route = n.actionRoute;
    if (route != null && route.trim().isNotEmpty) {
      Get.back(); // đóng bottom sheet
      Get.toNamed(route);
    }
  }
}
