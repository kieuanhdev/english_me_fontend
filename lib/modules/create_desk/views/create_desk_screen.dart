import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:englishme/core/layout/app_spacing.dart';
import 'package:englishme/core/widgets/app_text_field.dart';
import 'package:englishme/core/widgets/common_app_bar.dart';
import 'package:englishme/modules/create_desk/controllers/create_desk_controller.dart';
import 'package:englishme/theme/app_theme.dart';

class CreateDeskScreen extends StatelessWidget {
  const CreateDeskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CommonAppBar(
        title: 'Tạo bộ thẻ mới',
        isTranslate: false,
        actions: [
          Obx(
            () {
              final c = Get.find<CreateDeskController>();
              final busy = c.isSubmitting.value;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: busy ? null : c.createDesk,
                  child: Text(
                    'Tạo',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: busy ? AppColors.textSecondary : AppColors.primary,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: GetBuilder<CreateDeskController>(
          builder: (c) {
            return Form(
              key: c.formKey,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeaderHero(),
                        AppGap.h24,
                        _SectionTitle(title: 'Tên bộ thẻ', required: true),
                        AppGap.h10,
                        AppTextField(
                          label: null,
                          hintText: 'Ví dụ: Tiếng Anh Giao Tiếp',
                          controller: c.titleCtrl,
                          isTranslate: false,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên bộ thẻ';
                            return null;
                          },
                        ),
                        AppGap.h22,
                        const _SectionTitle(title: 'Mô tả'),
                        AppGap.h10,
                        TextFormField(
                          controller: c.descCtrl,
                          maxLines: 4,
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Bộ thẻ này tập trung vào các cụm từ phổ biến...',
                            hintStyle: AppTypography.bodyLarge.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceContainerHigh,
                            contentPadding: const EdgeInsets.all(18),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                        ),
                        AppGap.h24,
                        _ColorSection(controller: c),
                        AppGap.h24,
                        _IconSection(controller: c),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: AppColors.surface.withValues(alpha: 0.9),
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                      child: Obx(
                        () => _PrimaryCreateButton(
                          isLoading: c.isSubmitting.value,
                          onPressed: c.createDesk,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bắt đầu hành trình mới',
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 26,
                    color: AppColors.primary,
                    height: 1.1,
                  ),
                ),
                AppGap.h8,
                Text(
                  'Tổ chức kiến thức theo cách của riêng bạn với thiết kế tối giản.',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 76,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFDEE0FF), Color(0xFFF3F3F4)],
            ),
          ),
          child: const Icon(Icons.auto_stories_rounded, color: AppColors.primary, size: 34),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.required = false});
  final String title;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.displayLarge.copyWith(
            fontSize: 19,
            color: AppColors.primary,
          ),
        ),
        if (required)
          Text(
            'Required',
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: const Color(0x99643900),
            ),
          ),
      ],
    );
  }
}

class _ColorSection extends StatelessWidget {
  const _ColorSection({required this.controller});
  final CreateDeskController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Chọn màu sắc'),
          AppGap.h6,
          Text(
            'Sử dụng màu sắc để phân loại các chủ đề khác nhau.',
            style: AppTypography.bodyLarge.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          AppGap.h16,
          Obx(
            () => Wrap(
              spacing: 14,
              runSpacing: 14,
              children: CreateDeskController.colorOptions.map((hex) {
                final color = _hexToColor(hex);
                final selected = controller.selectedColor.value == hex;
                return GestureDetector(
                  onTap: () => controller.selectedColor.value = hex,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(
                        color: selected ? AppColors.primary.withValues(alpha: 0.25) : Colors.transparent,
                        width: 5,
                      ),
                      boxShadow: selected
                          ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 8)]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconSection extends StatelessWidget {
  const _IconSection({required this.controller});
  final CreateDeskController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Chọn biểu tượng'),
        AppGap.h14,
        Obx(
          () => GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            children: CreateDeskController.iconOptions.map((iconName) {
              final selected = controller.selectedIcon.value == iconName;
              return GestureDetector(
                onTap: () => controller.selectedIcon.value = iconName,
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFE9EEFF) : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: selected
                        ? Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2)
                        : null,
                  ),
                  child: Icon(
                    _mapIcon(iconName),
                    size: 30,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PrimaryCreateButton extends StatelessWidget {
  const _PrimaryCreateButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isLoading ? null : AppColors.primaryGradient,
            color: isLoading ? AppColors.surfaceContainerHigh : null,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else ...[
                const Icon(Icons.add_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Tạo bộ thẻ',
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
  }
}

Color _hexToColor(String hex) {
  final normalized = hex.replaceFirst('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}

IconData _mapIcon(String iconName) {
  return switch (iconName) {
    'book' => Icons.menu_book_rounded,
    'edit' => Icons.edit_rounded,
    'mic' => Icons.mic_rounded,
    'chat_bubble' => Icons.chat_bubble_rounded,
    'translate' => Icons.translate_rounded,
    'school' => Icons.school_rounded,
    _ => Icons.style_rounded,
  };
}
