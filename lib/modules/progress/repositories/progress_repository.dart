import 'package:englishme/modules/progress/models/progress_model.dart';

class ProgressRepository {
  Future<ProgressData> getProgressData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    return ProgressData.mock();
  }
}
