import 'package:get/get.dart';
import 'package:englishme/core/services/sound_service.dart';
import 'package:englishme/modules/learn/models/curriculum_models.dart';
import 'package:englishme/modules/learn/repositories/curriculum_repository.dart';

/// Điều khiển Level Checkpoint Test (lên cấp CEFR).
/// FE chỉ thu thập ĐÁP ÁN THÔ — điểm do BE chấm.
class CheckpointController extends GetxController {
  CheckpointController(this._repo);
  final CurriculumRepository _repo;

  final loading = true.obs;
  final error = ''.obs;
  final state = Rxn<CheckpointState>();

  // làm bài
  final index = 0.obs;
  final selected = Rxn<String>(); // mcq | listening
  final text = ''.obs; // fill_blank | translation | error_correction
  final RxList<int> order = <int>[].obs; // sentence_ordering
  final List<Map<String, dynamic>> _answers = [];

  // kết quả
  final submitting = false.obs;
  final result = Rxn<CheckpointResult>();

  /// Đã bắn confetti chúc mừng lên cấp chưa (one-shot, tránh bắn lại mỗi
  /// rebuild của màn kết quả).
  bool levelUpConfettiShown = false;

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
      state.value = await _repo.getCheckpoint(level);
    } catch (e) {
      error.value = 'Không tải được bài kiểm tra.';
    } finally {
      loading.value = false;
    }
  }

  CurriculumActivity? get current {
    final qs = state.value?.questions ?? [];
    if (index.value >= qs.length) return null;
    return qs[index.value];
  }

  bool get canSubmitCurrent {
    final a = current;
    if (a == null) return false;
    if (a.isTextInput) return text.value.trim().isNotEmpty;
    if (a.isOrdering) return order.length == a.tokens.length;
    return selected.value != null;
  }

  void select(String optionId) => selected.value = optionId;
  void type(String t) => text.value = t;
  void toggleOrder(int i) =>
      order.contains(i) ? order.remove(i) : order.add(i);
  void resetOrder() => order.clear();

  Map<String, dynamic> _raw(CurriculumActivity a) {
    final m = <String, dynamic>{'activityId': a.id};
    if (a.isTextInput) {
      m['text'] = text.value;
    } else if (a.isOrdering) {
      m['order'] = List<int>.from(order);
    } else {
      m['selectedOptionId'] = selected.value;
    }
    return m;
  }

  Future<void> next() async {
    final qs = state.value?.questions ?? [];
    final a = current;
    if (a != null) _answers.add(_raw(a));
    selected.value = null;
    text.value = '';
    order.clear();
    if (index.value < qs.length - 1) {
      index.value++;
    } else {
      submitting.value = true;
      try {
        final r = await _repo.submitCheckpoint(level, _answers);
        result.value = r;
        // Lên cấp → fanfare; chỉ hoàn thành → tiếng hoàn thành thường.
        SoundService.to.play(
          r.leveledUp ? AppSound.levelUp : AppSound.complete,
        );
      } catch (e) {
        error.value = 'Nộp bài thất bại.';
      } finally {
        submitting.value = false;
      }
    }
  }
}
