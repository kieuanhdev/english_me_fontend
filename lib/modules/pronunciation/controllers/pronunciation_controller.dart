import 'dart:io';

import 'package:dio/dio.dart';
import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/data/models/pronunciation_models.dart';
import 'package:englishme/data/repositories/pronunciation_repository.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class PronunciationController extends GetxController {
  late final PronunciationRepository _repository;
  final AudioRecorder _recorder = AudioRecorder();

  final exercises = <PronunciationExercise>[].obs;
  final isLoadingExercises = false.obs;
  final selectedExercise = Rxn<PronunciationExercise>();

  final isRecording = false.obs;
  final isAssessing = false.obs;
  final recordedFilePath = Rxn<String>();
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
    _recorder.dispose();
    super.onClose();
  }

  Future<void> fetchExercises() async {
    isLoadingExercises.value = true;
    try {
      exercises.value = await _repository.getExercises();
    } on DioException {
      Get.snackbar('Lỗi', 'Không thể tải danh sách bài tập.');
    } finally {
      isLoadingExercises.value = false;
    }
  }

  void selectExercise(PronunciationExercise exercise) {
    selectedExercise.value = exercise;
    recordedFilePath.value = null;
    feedback.value = null;
  }

  Future<void> startRecording() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      Get.snackbar('Quyền bị từ chối', 'Cần cấp quyền microphone để ghi âm.');
      return;
    }

    if (await _recorder.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/pronunciation_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      recordedFilePath.value = path;
      isRecording.value = true;
    }
  }

  Future<void> stopRecording() async {
    if (!isRecording.value) return;
    final path = await _recorder.stop();
    isRecording.value = false;
    if (path != null) {
      recordedFilePath.value = path;
      canGoToResult.value = true;
    }
  }

  Future<void> assessRecording() async {
    final path = recordedFilePath.value;
    final exercise = selectedExercise.value;
    if (path == null || exercise == null) return;

    isAssessing.value = true;
    try {
      final file = File(path);
      feedback.value = await _repository.assessPronunciation(
        audioFile: file,
        exerciseId: exercise.id,
        expectedText: exercise.text,
      );
    } on DioException catch (e) {
      final msg =
          (e.response?.data is Map<String, dynamic>)
              ? (e.response?.data['message'] as String? ??
                  'Không thể phân tích phát âm.')
              : 'Không thể kết nối đến máy chủ.';
      Get.snackbar('Lỗi', msg);
    } catch (_) {
      Get.snackbar('Lỗi', 'Đã có lỗi xảy ra khi phân tích.');
    } finally {
      isAssessing.value = false;
    }
  }
}
