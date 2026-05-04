import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_text_field.dart';
import 'package:englishme/core/widgets/common_app_bar.dart';
import 'package:englishme/modules/add_flashcard/controllers/add_flashcard_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class AddFlashcardScreen extends StatelessWidget {
  const AddFlashcardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AddFlashcardController>()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) Get.back();
      });
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: CommonAppBar(title: 'Flashcard', isTranslate: false),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final c = Get.find<AddFlashcardController>();
    final pageTitle = c.isEditMode ? 'Sửa thẻ' : 'Từ mới';
    final headline = c.isEditMode ? 'Sửa thẻ từ vựng' : 'Tạo thẻ từ vựng';
    final subtitle = c.isEditMode
        ? 'Cập nhật lại thông tin để thẻ rõ nghĩa và dễ nhớ hơn.'
        : 'Ghi lại những từ mới bạn vừa học để xây dựng vốn từ vựng học thuật riêng mình.';
    final submitLabel = c.isEditMode ? 'Lưu thay đổi' : 'Lưu thẻ';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CommonAppBar(
        title: pageTitle,
        isTranslate: false,
        showBackButton: true,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Obx(() {
            final busy = c.isSubmitting.value;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: busy ? null : c.submit,
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: busy ? null : AppColors.primaryGradient,
                    color: busy ? AppColors.surfaceContainerHigh : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: busy
                        ? null
                        : const [
                            BoxShadow(
                              color: Color(0x3324389C),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (busy)
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      else ...[
                        const Icon(Icons.save_rounded, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          submitLabel,
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
      body: Form(
        key: c.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headline,
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 28,
                  height: 1.1,
                  color: AppColors.primary,
                ),
              ),
              AppGap.h10,
              Text(
                subtitle,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AppGap.h28,
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tinyLabel('Từ tiếng Anh'),
                          AppGap.h8,
                          AppTextField(
                            label: null,
                            hintText: 'Ví dụ: Ephemeral',
                            controller: c.wordCtrl,
                            isTranslate: false,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Vui lòng nhập từ';
                              }
                              return null;
                            },
                          ),
                          AppGap.h20,
                          Row(
                            children: [
                              Expanded(child: _tinyLabel('Phiên âm IPA')),
                              Tooltip(
                                message: 'Phiên âm quốc tế giúp bạn đọc đúng từ.',
                                child: Icon(
                                  Icons.info_outline_rounded,
                                  size: 18,
                                  color: AppColors.iconMuted,
                                ),
                              ),
                            ],
                          ),
                          AppGap.h8,
                          AppTextField(
                            label: null,
                            hintText: '/ɪˈfɛmərəl/',
                            controller: c.ipaCtrl,
                            isTranslate: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tinyLabel('Từ loại'),
                          AppGap.h12,
                          Obx(() => Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: AddFlashcardController.posLabels.entries
                                    .map(
                                      (e) => _PosChip(
                                        label: e.value,
                                        selected: c.selectedPosKey.value == e.key,
                                        onTap: () => c.selectedPosKey.value = e.key,
                                      ),
                                    )
                                    .toList(),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tinyLabel('Nghĩa tiếng Việt'),
                          AppGap.h8,
                          AppTextField(
                            label: null,
                            hintText: 'Phù du, chóng tàn',
                            controller: c.meaningCtrl,
                            isTranslate: false,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Vui lòng nhập nghĩa';
                              }
                              return null;
                            },
                          ),
                          AppGap.h20,
                          _tinyLabel('Câu ví dụ'),
                          AppGap.h8,
                          TextFormField(
                            controller: c.exampleCtrl,
                            maxLines: 4,
                            style: AppTypography.bodyLarge.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                              height: 1.35,
                            ),
                            decoration: InputDecoration(
                              hintText: 'The beauty of the sunset is ephemeral.',
                              hintStyle: AppTypography.bodyLarge.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceContainerHigh,
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFCED8E2), width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFCED8E2), width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h28,
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF24389C),
                              Color(0xFF3F51B5),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Text(
                          'Học sâu, nhớ lâu.',
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _tinyLabel(String text) {
  return Text(
    text.toUpperCase(),
    style: AppTypography.bodyLarge.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: AppColors.primary.withValues(alpha: 0.72),
    ),
  );
}

class _PosChip extends StatelessWidget {
  const _PosChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            color: selected ? null : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x3324389C),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
