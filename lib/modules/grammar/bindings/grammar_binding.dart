import 'package:englishme/core/network/dio_client.dart';
import 'package:englishme/modules/grammar/repositories/grammar_repository.dart';
import 'package:englishme/modules/grammar/controllers/grammar_controller.dart';
import 'package:get/get.dart';

class GrammarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GrammarRepository>(
      () => GrammarRepository(DioClient.instance),
      fenix: true,
    );
    Get.lazyPut<GrammarController>(
      () => GrammarController(Get.find<GrammarRepository>()),
      fenix: true,
    );
  }
}
