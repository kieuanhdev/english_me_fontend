import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/services/tts_service.dart';
import 'package:englishme/core/widgets/app_main_app_bar.dart';
import 'package:englishme/modules/conversation/controllers/conversation_controller.dart';
import 'package:englishme/modules/conversation/models/conversation_models.dart';
import 'package:englishme/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Màn hội thoại voice với AI. Bong bóng chat + nút mic + bộ đếm lượt.
class ConversationChatScreen extends StatelessWidget {
  const ConversationChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ConversationController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => AppMainAppBar(
                  title: ctrl.topic.value.isEmpty
                      ? 'Hội thoại'
                      : ctrl.topic.value,
                  showBack: true,
                  showSettings: false,
                  showNotification: false,
                  horizontalPadding: 0,
                  onBack: Get.back,
                ),
              ),
              AppGap.h8,
              Obx(() => _TurnCounter(
                    used: ctrl.userTurnsUsed.value,
                    max: ConversationController.maxUserTurns,
                  )),
              AppGap.h12,
              Expanded(
                child: Obx(() {
                  final msgs = ctrl.messages.toList();
                  return ListView.builder(
                    reverse: true,
                    itemCount: msgs.length,
                    itemBuilder: (context, i) {
                      final msg = msgs[msgs.length - 1 - i];
                      return _ChatBubble(
                        message: msg,
                        onReplay: () => ctrl.replay(msg.content),
                      );
                    },
                  );
                }),
              ),
              _StatusLine(ctrl: ctrl),
              AppGap.h8,
              _BottomBar(ctrl: ctrl),
            ],
          ),
        ),
      ),
    );
  }
}

class _TurnCounter extends StatelessWidget {
  const _TurnCounter({required this.used, required this.max});

  final int used;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.mic_rounded, size: 16, color: AppColors.textSecondary),
        AppGap.w8,
        Text(
          'Lượt nói: $used/$max',
          style: AppTypography.body.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.onReplay});

  final ChatMessage message;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final tts = Get.find<TtsService>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Icon(Icons.smart_toy_rounded,
                  size: 18, color: AppColors.primary),
            ),
            AppGap.w8,
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTypography.body.copyWith(
                      fontSize: 15,
                      color: isUser ? Colors.white : AppColors.onSurface,
                    ),
                  ),
                  if (!isUser) ...[
                    AppGap.h6,
                    InkWell(
                      onTap: onReplay,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Obx(() {
                        final speaking = tts.isSpeaking.value &&
                            tts.speakingText.value == message.content;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              speaking
                                  ? Icons.volume_up_rounded
                                  : Icons.replay_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            AppGap.w6,
                            Text(
                              speaking ? 'Đang đọc' : 'Nghe lại',
                              style: AppTypography.body.copyWith(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.ctrl});

  final ConversationController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String text;
      Color color = AppColors.textSecondary;
      if (ctrl.phase.value == ConversationPhase.summarizing) {
        text = 'Đang tổng kết...';
      } else if (ctrl.isThinking.value) {
        text = 'AI đang trả lời...';
        color = AppColors.primary;
      } else if (ctrl.isRecording.value) {
        text = ctrl.liveTranscript.value.isEmpty
            ? 'Đang nghe...'
            : ctrl.liveTranscript.value;
        color = AppColors.danger;
      } else if (!ctrl.hasTurnsLeft) {
        text = 'Hết lượt nói. Nhấn "Kết thúc & nhận xét".';
      } else {
        text = 'Nhấn mic và nói tiếng Anh';
      }
      return SizedBox(
        width: double.infinity,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(fontSize: 13, color: color),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    });
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.ctrl});

  final ConversationController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summarizing = ctrl.phase.value == ConversationPhase.summarizing;
      final recording = ctrl.isRecording.value;
      final canRecord = ctrl.canRecord;
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: summarizing ? null : ctrl.finishAndSummarize,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              icon: const Icon(Icons.flag_rounded, size: 18),
              label: const Text('Kết thúc & nhận xét'),
            ),
          ),
          AppGap.w12,
          GestureDetector(
            onTap: recording
                ? ctrl.stopRecording
                : (canRecord ? ctrl.startRecording : null),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !canRecord && !recording
                    ? AppColors.surfaceContainerHigh
                    : (recording ? AppColors.danger : AppColors.primary),
              ),
              child: Icon(
                recording ? Icons.stop_rounded : Icons.mic_rounded,
                color: !canRecord && !recording
                    ? AppColors.textSecondary
                    : Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      );
    });
  }
}
