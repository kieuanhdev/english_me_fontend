import 'package:englishme/core/widgets/app_bottom_nav.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/chat_ai/controllers/chat_ai_controller.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';

class ChatAiScreen extends GetView<ChatAiController> {
  const ChatAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final markdownStyle = MarkdownStyleSheet(
      p: AppTypography.bodyLarge.copyWith(
        color: AppColors.onSurface,
        fontSize: 14,
      ),
      h1: AppTypography.displayLarge.copyWith(fontSize: 18),
      h2: AppTypography.headlineMedium.copyWith(fontSize: 16),
      h3: AppTypography.headlineMedium.copyWith(fontSize: 14),
      listBullet: AppTypography.bodyLarge.copyWith(
        color: AppColors.onSurface,
        fontSize: 14,
      ),
      tableHead: AppTypography.bodyLarge.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
        fontSize: 12,
      ),
      tableBody: AppTypography.bodyLarge.copyWith(
        color: AppColors.onSurface,
        fontSize: 12,
      ),
      blockquote: AppTypography.bodyLarge.copyWith(
        color: AppColors.textSecondary,
        fontSize: 13,
      ),
      code: AppTypography.bodyLarge.copyWith(
        color: AppColors.primaryContainer,
        fontSize: 12,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: const AppBottomNav(initialIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),
            const AppMainAppBar(title: 'Chat AI'),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final item = controller.messages[index];
                    final isUser = item.role == 'user';
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.78,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.primary
                              : AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                          border: isUser
                              ? null
                              : Border.all(
                                  color: AppColors.outlineVariant,
                                  width: 1,
                                ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isUser)
                              Text(
                                item.content,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              )
                            else
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: MarkdownBody(
                                  data: item.content,
                                  shrinkWrap: true,
                                  selectable: true,
                                  softLineBreak: true,
                                  styleSheet: markdownStyle,
                                ),
                              ),
                            if (!isUser && (item.model?.isNotEmpty ?? false)) ...[
                              const SizedBox(height: 8),
                              Text(
                                item.model!,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            _InputComposer(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _InputComposer extends StatelessWidget {
  const _InputComposer({required this.controller});

  final ChatAiController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border(
            top: BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.inputController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.sendCurrentMessage(),
                decoration: InputDecoration(
                  hintText: 'Nhap tin nhan...',
                  hintStyle: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() {
              return IconButton.filled(
                onPressed: controller.isSending.value
                    ? null
                    : controller.sendCurrentMessage,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.secondaryContainer,
                ),
                icon: controller.isSending.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
              );
            }),
          ],
        ),
      ),
    );
  }
}
