import 'dart:async';

import 'package:dio/dio.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/core/utils/app_notify.dart';
import 'package:englishme/core/values/app_strings.dart';
import 'package:englishme/modules/pronunciation/models/pronunciation_models.dart';
import 'package:englishme/modules/pronunciation/repositories/pronunciation_repository.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class PronunciationController extends GetxController {
  late final PronunciationRepository _repository;
  final SpeechToText _speech = SpeechToText();
  bool _speechReady = false;

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
    _repository = PronunciationRepository(DioClient.instance);
    fetchExercises();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _speech.cancel();
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
    isRecording.value = false;
    if (liveTranscript.value.trim().isNotEmpty) {
      canGoToResult.value = true;
    }
  }

  void _onSpeechStatus(String status) {
    // STT tự dừng khi user im lặng -> đồng bộ lại cờ recording.
    if (status == 'done' || status == 'notListening') {
      if (isRecording.value) {
        isRecording.value = false;
        if (liveTranscript.value.trim().isNotEmpty) {
          canGoToResult.value = true;
        }
      }
    }
  }

  /// Gửi transcript lên backend chấm điểm thật (DeepSeek).
  Future<void> assessRecording() async {
    final exercise = selectedExercise.value;
    final spoken = liveTranscript.value.trim();
    if (exercise == null || spoken.isEmpty) return;

    isAssessing.value = true;
    try {
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
