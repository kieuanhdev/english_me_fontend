import 'package:englishme/modules/conversation/bindings/conversation_binding.dart';
import 'package:englishme/modules/conversation/views/conversation_chat_screen.dart';
import 'package:englishme/modules/conversation/views/conversation_summary_screen.dart';
import 'package:englishme/modules/conversation/views/conversation_topic_screen.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:get/get.dart';

abstract class ConversationPages {
  static final pages = [
    GetPage(
      name: AppRoutes.conversation,
      page: () => const ConversationTopicScreen(),
      binding: ConversationBinding(),
    ),
    GetPage(
      name: AppRoutes.conversationChat,
      page: () => const ConversationChatScreen(),
      binding: ConversationBinding(),
    ),
    GetPage(
      name: AppRoutes.conversationSummary,
      page: () => const ConversationSummaryScreen(),
      binding: ConversationBinding(),
    ),
  ];
}
