import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:englishme/core/utils/app_notify.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/pronunciation/models/pronunciation_models.dart';
import 'package:englishme/modules/pronunciation/repositories/pronunciation_repository.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';

class PronunciationController extends GetxController {
  final PronunciationRepository _repository;
  PronunciationController(this._repository);
  final SpeechToText _speech = SpeechToText();
  bool _speechReady = false;

  /// Ghi file audio để gửi Google Cloud STT (luồng chính). Đồng thời chạy
  /// speech_to_text on-device để có transcript fallback khi Cloud lỗi/tắt.
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordedPath;

  final exercises = <PronunciationExercise>[].obs;
  final isLoadingExercises = false.obs;
  final selectedExercise = Rxn<PronunciationExercise>();

  /// Các mức CEFR hiển thị dạng chip lọc. '' = tất cả (theo level người học).
  static const levelFilters = ['', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  final selectedLevel = ''.obs;
  final searchKeyword = ''.obs;
  Timer? _searchDebounce;

  final isRecording = false.obs;
  final isAssessing = false.obs;

  /// Text người dùng đang/đã nói (live transcript từ STT).
  final liveTranscript = ''.obs;
  final feedback = Rxn<PronunciationFeedback>();

  final canGoToResult = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExercises();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _speech.cancel();
    _recorder.dispose();
    super.onClose();
  }

  Future<void> fetchExercises() async {
    isLoadingExercises.value = true;
    try {
      exercises.value = await _repository.getExercises(
        level: selectedLevel.value,
        keyword: searchKeyword.value,
      );
    } on DioException {
      AppNotify.error(T.errorGeneric.tr, message: T.errorLoadPronunciation.tr);
    } finally {
      isLoadingExercises.value = false;
    }
  }

  /// Chọn chip lọc level rồi tải lại danh sách.
  void setLevelFilter(String level) {
    if (selectedLevel.value == level) return;
    selectedLevel.value = level;
    fetchExercises();
  }

  /// Tìm theo nội dung câu, debounce 400ms để tránh gọi API liên tục.
  void onSearchChanged(String value) {
    searchKeyword.value = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), fetchExercises);
  }

  void selectExercise(PronunciationExercise exercise) {
    selectedExercise.value = exercise;
    liveTranscript.value = '';
    feedback.value = null;
    canGoToResult.value = false;
  }

  Future<void> startRecording() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      AppNotify.error(T.errorPermissionDenied.tr, message: T.errorMicPermission.tr);
      return;
    }

    if (!_speechReady) {
      _speechReady = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: (e) {
          isRecording.value = false;
          AppNotify.error(T.errorGeneric.tr, message: T.errorPronunciationGeneric.tr);
        },
      );
    }
    if (!_speechReady) {
      AppNotify.error(T.errorGeneric.tr, message: T.errorPronunciationGeneric.tr);
      return;
    }

    liveTranscript.value = '';
    feedback.value = null;
    canGoToResult.value = false;
    isRecording.value = true;

    // Ghi file WAV PCM 16kHz mono cho Google Cloud STT (luồng chính).
    _recordedPath = null;
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/pron_${DateTime.now().millisecondsSinceEpoch}.wav';
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: path,
        );
        _recordedPath = path;
      }
    } catch (_) {
      // Ghi file lỗi -> bỏ qua, vẫn còn transcript on-device để fallback.
      _recordedPath = null;
    }

    // Chạy STT on-device song song -> transcript fallback khi Cloud lỗi/tắt.
    await _speech.listen(
      onResult: (result) {
        liveTranscript.value = result.recognizedWords;
      },
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        localeId: 'en_US',
      ),
    );
  }

  Future<void> stopRecording() async {
    if (!isRecording.value) return;
    await _speech.stop();
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {
      _recordedPath = null;
    }
    isRecording.value = false;
    if (liveTranscript.value.trim().isNotEmpty || _recordedPath != null) {
      canGoToResult.value = true;
    }
  }

  void _onSpeechStatus(String status) {
    // STT tự dừng khi user im lặng -> đồng bộ lại cờ recording + dừng ghi file.
    if (status == 'done' || status == 'notListening') {
      if (isRecording.value) {
        unawaited(_stopRecorderIfActive());
        isRecording.value = false;
        if (liveTranscript.value.trim().isNotEmpty || _recordedPath != null) {
          canGoToResult.value = true;
        }
      }
    }
  }

  /// Dừng ghi âm nếu đang chạy. Lỗi recorder không quan trọng -> nuốt im lặng.
  Future<void> _stopRecorderIfActive() async {
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {
      // recorder lỗi khi dừng -> bỏ qua, không ảnh hưởng luồng chấm điểm.
    }
  }

  /// Chấm phát âm: ưu tiên gửi FILE AUDIO lên Google Cloud STT (luồng chính,
  /// đề cương MT4). STT chưa bật / lỗi (HTTP 422) hoặc không ghi được file ->
  /// fallback gửi transcript on-device qua /assess-text.
  Future<void> assessRecording() async {
    final exercise = selectedExercise.value;
    if (exercise == null) return;
    final spoken = liveTranscript.value.trim();
    final path = _recordedPath;
    if (path == null && spoken.isEmpty) return;

    isAssessing.value = true;
    try {
      // Luồng chính: upload audio -> Cloud STT chấm.
      if (path != null && File(path).existsSync()) {
        try {
          feedback.value = await _repository.assessAudio(
            audioPath: path,
            referenceText: exercise.text,
            exerciseId: exercise.id,
          );
          return;
        } on DioException catch (e) {
          // 422 = STT chưa bật / không nhận ra -> fallback transcript on-device.
          if (e.response?.statusCode != 422) rethrow;
        }
      }

      // Fallback: transcript on-device.
      if (spoken.isEmpty) {
        AppNotify.error(T.errorGeneric.tr, message: T.errorPronunciationGeneric.tr);
        return;
      }
      feedback.value = await _repository.assessTranscript(
        referenceText: exercise.text,
        spokenText: spoken,
        exerciseId: exercise.id,
      );
    } on DioException catch (e) {
      final msg = (e.response?.data is Map<String, dynamic>)
          ? (e.response?.data['message'] as String? ??
                T.errorPronunciationAnalysis.tr)
          : T.errorPronunciationServer.tr;
      AppNotify.error(T.errorGeneric.tr, message: msg);
    } catch (_) {
      AppNotify.error(T.errorGeneric.tr, message: T.errorPronunciationGeneric.tr);
    } finally {
      isAssessing.value = false;
    }
  }
}
