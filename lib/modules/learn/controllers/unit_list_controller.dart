import 'package:englishme/core/utils/app_notify.dart';
import 'package:get/get.dart';
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

  Future<void> load() async {
    loading.value = true;
    error.value = '';
    try {
      data.value = await _repo.getLevelUnits(level);
    } catch (e) {
      error.value = 'Không tải được danh sách Unit.';
    } finally {
      loading.value = false;
    }
  }

  Future<void> openUnit(CurriculumUnit unit) async {
    if (unit.isLocked) {
      AppNotify.warning('Đã khoá', message: 'Hoàn thành Unit trước để mở khoá Unit này.');
      return;
    }
    await Get.toNamed(AppRoutes.curriculumUnitDetail,
        arguments: {'unitId': unit.id});
    load(); // refresh khi quay lại
  }
}
