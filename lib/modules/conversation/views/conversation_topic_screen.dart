import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_button.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/conversation/controllers/conversation_controller.dart';
import 'package:englishme/modules/conversation/models/conversation_models.dart';
import 'package:englishme/routes/app_routes.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Màn chọn chủ đề luyện hội thoại: chủ đề có sẵn hoặc tự nhập.
class ConversationTopicScreen extends StatefulWidget {
  const ConversationTopicScreen({super.key});

  @override
  State<ConversationTopicScreen> createState() =>
      _ConversationTopicScreenState();
}

class _ConversationTopicScreenState extends State<ConversationTopicScreen> {
  static const _topics = <ConversationTopic>[
    ConversationTopic(
      titleVi: 'Cuộc sống thường ngày',
      promptValue: 'daily life and routines',
      icon: Icons.wb_sunny_rounded,
    ),
    ConversationTopic(
      titleVi: 'Đồ ăn & nấu nướng',
      promptValue: 'food and cooking',
      icon: Icons.restaurant_rounded,
    ),
    ConversationTopic(
      titleVi: 'Du lịch',
      promptValue: 'travel and places',
      icon: Icons.flight_takeoff_rounded,
    ),
    ConversationTopic(
      titleVi: 'Sở thích',
      promptValue: 'hobbies and free time',
      icon: Icons.sports_esports_rounded,
    ),
    ConversationTopic(
      titleVi: 'Công việc & học tập',
      promptValue: 'work and study',
      icon: Icons.work_rounded,
    ),
    ConversationTopic(
      titleVi: 'Mua sắm',
      promptValue: 'shopping',
      icon: Icons.shopping_bag_rounded,
    ),
    ConversationTopic(
      titleVi: 'Phim & âm nhạc',
      promptValue: 'movies and music',
      icon: Icons.movie_rounded,
    ),
    ConversationTopic(
      titleVi: 'Thời tiết',
      promptValue: 'the weather',
      icon: Icons.cloud_rounded,
    ),
  ];

  final _customCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mở từ trong 1 bài giáo trình ("Luyện nói chủ đề bài này"): nhận topic gợi ý
    // từ tiêu đề bài → bắt đầu luôn, không bắt user chọn lại (B xoay quanh A).
    final args = Get.arguments;
    if (args is Map && args['topic'] is String) {
      final topic = (args['topic'] as String).trim();
      if (topic.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _start(topic));
      }
    }
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _start(String topicValue) {
    if (topicValue.trim().isEmpty) return;
    final ctrl = Get.find<ConversationController>();
    ctrl.startConversation(topicValue.trim());
    Get.toNamed(AppRoutes.conversationChat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppMainAppBar(
                title: 'Hội thoại với AI',
                showBack: true,
                showSettings: false,
                horizontalPadding: 0,
                onBack: Get.back,
              ),
              AppGap.h16,
              Text(
                'Chọn chủ đề trò chuyện',
                style: AppTypography.headlineMedium.copyWith(fontSize: 20),
              ),
              AppGap.h8,
              Text(
                'Nói chuyện tiếng Anh với AI như một người bạn. Bạn có 10 lượt nói mỗi phiên.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              AppGap.h20,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.25,
                        children: _topics
                            .map((t) => _TopicCard(
                                  topic: t,
                                  onTap: () => _start(t.promptValue),
                                ))
                            .toList(),
                      ),
                      AppGap.h24,
                      Text(
                        'Hoặc tự nhập chủ đề',
                        style: AppTypography.body
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      AppGap.h12,
                      TextField(
                        controller: _customCtrl,
                        decoration: InputDecoration(
                          hintText: 'VD: công nghệ, thể thao, gia đình...',
                          filled: true,
                          fillColor: AppColors.surfaceContainerLowest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            borderSide:
                                BorderSide(color: AppColors.outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            borderSide:
                                BorderSide(color: AppColors.outlineVariant),
                          ),
                        ),
                        onSubmitted: _start,
                      ),
                      AppGap.h12,
                      AppButton(
                        label: 'Bắt đầu trò chuyện',
                        isTranslate: false,
                        onPressed: () => _start(_customCtrl.text),
                      ),
                      AppGap.h16,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic, required this.onTap});

  final ConversationTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(topic.icon, color: AppColors.primary, size: 22),
              ),
              Flexible(
                child: Text(
                  topic.titleVi,
                  style:
                      AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
