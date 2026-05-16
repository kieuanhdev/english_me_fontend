import 'package:get/get.dart';
import 'package:englishme/modules/progress/models/progress_model.dart';
import 'package:englishme/modules/progress/repositories/progress_repository.dart';

enum ProgressLoadState { idle, loading, success, error }

class ProgressController extends GetxController {
  final ProgressRepository _repo;

  ProgressController(this._repo);

  final loadState = ProgressLoadState.idle.obs;
  final Rxn<ProgressData> data = Rxn<ProgressData>();

  /// Selected tab for XP chart: 0 = tuần, 1 = 2 tuần
  final selectedChartRange = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProgress();
  }

  Future<void> loadProgress() async {
    try {
      loadState.value = ProgressLoadState.loading;
      final result = await _repo.getProgressData();
      data.value = result;
      loadState.value = ProgressLoadState.success;
    } catch (_) {
      loadState.value = ProgressLoadState.error;
    }
  }

  List<WeeklyXpEntry> get chartEntries {
    final all = data.value?.xpHistory ?? [];
    if (selectedChartRange.value == 0) {
      return all.length > 7 ? all.sublist(all.length - 7) : all;
    }
    return all;
  }

  int get chartMaxXp {
    final entries = chartEntries;
    if (entries.isEmpty) return 100;
    final max = entries.map((e) => e.xp).reduce((a, b) => a > b ? a : b);
    return ((max / 20).ceil() * 20).clamp(20, 200);
  }

  void selectChartRange(int index) => selectedChartRange.value = index;
}
