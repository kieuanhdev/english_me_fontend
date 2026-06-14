import 'package:get/get.dart';

import 'package:englishme/modules/progress/models/progress_model.dart';
import 'package:englishme/modules/progress/repositories/progress_repository.dart';
import 'package:englishme/modules/pronunciation/models/pronunciation_models.dart';
import 'package:englishme/modules/pronunciation/repositories/pronunciation_repository.dart';
import 'package:englishme/routes/app_routes.dart';

/// 1 mục kỹ năng trên màn "Kỹ năng cần cải thiện".
class WeakSkillItem {
  final String key; // 'vocabulary' | 'grammar' | 'pronunciation'
  final String label; // nhãn tiếng Việt
  final double share; // 0..1 (so với skill mạnh nhất)
  final String reason; // vì sao yếu / gợi ý

  const WeakSkillItem({
    required this.key,
    required this.label,
    required this.share,
    required this.reason,
  });

  bool get isWeak => share < 0.5;
}

enum WeakSkillsLoad { idle, loading, success, error }

/// Màn "Kỹ năng cần cải thiện" (cá nhân hóa):
///   - Yếu kỹ năng gì  -> per-skill share (từ /users/me/progress)
///   - Yếu ở đâu        -> phát âm: list từ hay sai (/pronunciation/insights)
///   - Luyện ngay       -> điều hướng tới đích phù hợp (phát âm -> AI hội thoại).
class WeakSkillsController extends GetxController {
  final ProgressRepository _progressRepo;
  final PronunciationRepository _pronRepo;
  WeakSkillsController(this._progressRepo, this._pronRepo);

  final loadState = WeakSkillsLoad.idle.obs;
  final Rxn<SkillBreakdown> breakdown = Rxn<SkillBreakdown>();
  final Rxn<PronunciationInsight> pronInsight = Rxn<PronunciationInsight>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loadState.value = WeakSkillsLoad.loading;
    try {
      // Tải song song: per-skill + chi tiết phát âm yếu.
      final results = await Future.wait([
        _progressRepo.getSkillBreakdown(),
        _loadPronInsightSafe(),
      ]);
      breakdown.value = results[0] as SkillBreakdown;
      pronInsight.value = results[1] as PronunciationInsight?;
      loadState.value = WeakSkillsLoad.success;
    } catch (_) {
      loadState.value = WeakSkillsLoad.error;
    }
  }

  Future<PronunciationInsight?> _loadPronInsightSafe() async {
    try {
      return await _pronRepo.getInsights(limit: 8);
    } catch (_) {
      return null; // chưa luyện phát âm lần nào -> không có insight, không vỡ màn.
    }
  }

  /// Danh sách kỹ năng, SẮP XẾP yếu nhất lên đầu (share thấp -> trước).
  List<WeakSkillItem> get skills {
    final b = breakdown.value;
    if (b == null) return const [];
    final items = <WeakSkillItem>[
      WeakSkillItem(
        key: 'vocabulary',
        label: 'Từ vựng',
        share: b.vocabulary,
        reason: _reasonFor('vocabulary', b.vocabulary),
      ),
      WeakSkillItem(
        key: 'grammar',
        label: 'Ngữ pháp',
        share: b.grammar,
        reason: _reasonFor('grammar', b.grammar),
      ),
      WeakSkillItem(
        key: 'reading',
        label: 'Đọc',
        share: b.reading,
        reason: _reasonFor('reading', b.reading),
      ),
      WeakSkillItem(
        key: 'pronunciation',
        label: 'Phát âm',
        share: b.pronunciation,
        reason: _reasonFor('pronunciation', b.pronunciation),
      ),
    ]..sort((a, c) => a.share.compareTo(c.share));
    return items;
  }

  bool get hasData {
    final b = breakdown.value;
    if (b == null) return false;
    return (b.vocabulary + b.grammar + b.reading + b.pronunciation) > 0;
  }

  String _reasonFor(String key, double share) {
    final pct = (share * 100).round();
    if (share <= 0) {
      return 'Bạn chưa luyện kỹ năng này — bắt đầu ngay để không bị hổng';
    }
    final base = switch (key) {
      'vocabulary' => 'Mở rộng vốn từ giúp bạn hiểu và diễn đạt tốt hơn',
      'grammar' => 'Nắm chắc ngữ pháp giúp câu của bạn chính xác hơn',
      'reading' => 'Luyện đọc giúp bạn hiểu văn bản nhanh và nắm ý chính tốt hơn',
      'pronunciation' =>
        'Luyện phát âm giúp người khác hiểu bạn dễ hơn khi nói',
      _ => '',
    };
    if (share < 0.5) {
      return 'Đây là kỹ năng bạn luyện ít nhất ($pct%) — $base';
    }
    return base;
  }

  /// Số từ phát âm yếu (để hiện badge trên card phát âm).
  int get weakWordCount => pronInsight.value?.weakestWords.length ?? 0;

  // ── Điều hướng "Luyện ngay" theo từng skill ──────────────────────────────
  void practice(String key) {
    switch (key) {
      case 'pronunciation':
        // Phát âm: ưu tiên luyện NÓI với AI hội thoại (chấm điểm + nhận xét).
        Get.toNamed(AppRoutes.conversation);
      case 'grammar':
        Get.toNamed(AppRoutes.grammarTheory);
      case 'reading':
        // Đọc: nội dung nằm trong bài học giáo trình → mở danh sách Unit để học.
        Get.toNamed(AppRoutes.curriculumUnits);
      case 'vocabulary':
      default:
        Get.toNamed(AppRoutes.flashcards);
    }
  }

  /// Luyện phát âm bài bản (đọc theo mẫu, chấm STT) — khác với hội thoại AI.
  void practicePronunciationDrill() => Get.toNamed(AppRoutes.pronunciation);

  /// Mở AI hội thoại để luyện nói.
  void openAiConversation() => Get.toNamed(AppRoutes.conversation);
}
