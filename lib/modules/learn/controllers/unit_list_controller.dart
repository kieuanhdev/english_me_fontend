import 'package:englishme/core/utils/app_notify.dart';
import 'package:get/get.dart';
import 'package:englishme/modules/learn/controllers/curriculum_progress_bus.dart';
import 'package:englishme/modules/learn/models/curriculum_models.dart';
import 'package:englishme/modules/learn/repositories/curriculum_repository.dart';
import 'package:englishme/routes/app_routes.dart';

class UnitListController extends GetxController {
  UnitListController(this._repo);
  final CurriculumRepository _repo;

  final loading = true.obs;
  final error = ''.obs;
  final data = Rxn<LevelUnits>();
  String level = 'A1';

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Map && arg['level'] != null) level = arg['level'].toString();
    load();
  }

  /// [silent] = true: refresh ngầm, giữ UI cũ, không bật loading spinner
  /// (tránh flash trắng khi back từ unit detail về).
  Future<void> load({bool silent = false}) async {
    if (!silent) loading.value = true;
    error.value = '';
    try {
      data.value = await _repo.getLevelUnits(level);
    } catch (e) {
      if (data.value == null) error.value = 'Không tải được danh sách Unit.';
    } finally {
      if (!silent) loading.value = false;
    }
  }

  Future<void> openUnit(CurriculumUnit unit) async {
    if (unit.isLocked) {
      AppNotify.warning('Đã khoá', message: 'Hoàn thành Unit trước để mở khoá Unit này.');
      return;
    }
    await Get.toNamed(AppRoutes.curriculumUnitDetail,
        arguments: {'unitId': unit.id});
    // Chỉ refetch khi có tiến độ mới (đã làm bài trong unit). Mở unit xem rồi
    // back ra → không đổi → bỏ qua, khỏi gọi API thừa.
    if (CurriculumProgressBus.consume()) load(silent: true);
  }
}
