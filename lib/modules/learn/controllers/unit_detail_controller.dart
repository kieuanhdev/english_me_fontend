import 'package:englishme/core/utils/app_notify.dart';
import 'package:get/get.dart';
import 'package:englishme/modules/learn/controllers/curriculum_progress_bus.dart';
import 'package:englishme/modules/learn/models/curriculum_models.dart';
import 'package:englishme/modules/learn/repositories/curriculum_repository.dart';
import 'package:englishme/routes/app_routes.dart';

class UnitDetailController extends GetxController {
  UnitDetailController(this._repo);
  final CurriculumRepository _repo;

  final loading = true.obs;
  final unit = Rxn<UnitDetail>();
  String unitId = '';

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Map && arg['unitId'] != null) unitId = arg['unitId'].toString();
    load();
  }

  /// [silent] = true: refresh data ngầm, KHÔNG bật loading spinner (tránh
  /// teardown + flash trắng toàn màn khi back từ lesson về). Giữ UI cũ,
  /// chỉ swap data mới → Obx chỉ rebuild tile thay đổi.
  Future<void> load({bool silent = false}) async {
    if (!silent) loading.value = true;
    try {
      unit.value = await _repo.getUnitDetail(unitId);
    } finally {
      if (!silent) loading.value = false;
    }
  }

  Future<void> openLesson(LessonListItem lesson) async {
    if (lesson.isLocked) {
      AppNotify.warning('Đã khoá', message: 'Hoàn thành bài trước để mở khoá bài này.');
      return;
    }
    await Get.toNamed(AppRoutes.curriculumLessonPlayer,
        arguments: {'lessonId': lesson.id});
    // Chỉ refetch khi lesson thực sự ghi tiến độ (xem lý thuyết / nộp bài).
    // Mở rồi back ra ngay → không đổi → bỏ qua, khỏi gọi API thừa.
    if (CurriculumProgressBus.isDirty) load(silent: true);
  }
}
