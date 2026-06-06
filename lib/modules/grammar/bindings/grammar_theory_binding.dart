import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/grammar/controllers/grammar_theory_controller.dart';
import 'package:englishme/modules/grammar/repositories/grammar_repository.dart';
import 'package:get/get.dart';

class GrammarTheoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GrammarRepository>(
      () => GrammarRepository(DioClient.instance),
      fenix: true,
    );
    Get.lazyPut<GrammarTheoryController>(
      () => GrammarTheoryController(Get.find<GrammarRepository>()),
      fenix: true,
    );
  }
}
