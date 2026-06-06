import 'package:englishme/core/utils/app_notify.dart';
import 'package:get/get.dart';
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

  Future<void> load() async {
    loading.value = true;
    try {
      unit.value = await _repo.getUnitDetail(unitId);
    } finally {
      loading.value = false;
    }
  }

  Future<void> openLesson(LessonListItem lesson) async {
    if (lesson.isLocked) {
      AppNotify.warning('Đã khoá', message: 'Hoàn thành bài trước để mở khoá bài này.');
      return;
    }
    await Get.toNamed(AppRoutes.curriculumLessonPlayer,
        arguments: {'lessonId': lesson.id});
    load();
  }
}
