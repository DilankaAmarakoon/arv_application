import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/theme.dart';

void showSuccessMessage(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        backgroundColor: AppColors.surface,
        elevation: 8,
        shadowColor: AppColors.shadow,
        title: Container(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Warning',
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 2,
                  shadowColor: AppColors.success.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                    horizontal: AppSpacing.lg,
                  ),
                ),
                child: Text(
                  'OK',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}