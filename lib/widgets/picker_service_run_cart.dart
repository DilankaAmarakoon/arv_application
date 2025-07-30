import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:staff_mangement/Models/picker_service_run_model.dart';

import '../constants/theme.dart';

class PickerServiceRunCart extends StatefulWidget {
  final String role;
  final PickerServiceRunModel serviceRun;
  final VoidCallback onTap;

  const PickerServiceRunCart({
    super.key,
    required this.role,
    required this.serviceRun,
    required this.onTap,
  });

  @override
  State<PickerServiceRunCart> createState() => _PickerServiceRunCartState();
}

class _PickerServiceRunCartState extends State<PickerServiceRunCart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.serviceRun.status == 'active';
    final isCompleted = widget.serviceRun.status == 'completed';

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: 3,
        shadowColor: AppColors.primary.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _animationController.forward(),
          onTapUp: (_) => _animationController.reverse(),
          onTapCancel: () => _animationController.reverse(),
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 70,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface,
                  AppColors.surface.withOpacity(0.95),
                ],
              ),
              border: Border.all(
                color: isCompleted
                    ? AppColors.success.withOpacity(0.3)
                    : isActive
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.divider,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                _buildServiceIcon(),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildServiceRunInfo()),
                _buildActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildServiceIcon() {
    Color iconColor;
    Color backgroundColor;
    Color borderColor;
    IconData iconData;

    if (widget.serviceRun.status == 'completed') {
      iconColor = AppColors.success;
      backgroundColor = AppColors.success.withOpacity(0.1);
      borderColor = AppColors.success.withOpacity(0.3);
      iconData = Icons.engineering;
    } else if (widget.serviceRun.status == 'active') {
      iconColor = AppColors.primary;
      backgroundColor = AppColors.primary.withOpacity(0.1);
      borderColor = AppColors.primary.withOpacity(0.3);
      iconData = Icons.engineering;
    } else {
      iconColor = AppColors.warning;
      backgroundColor = AppColors.warning.withOpacity(0.1);
      borderColor = AppColors.warning.withOpacity(0.3);
      iconData = Icons.engineering;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Widget _buildServiceRunInfo() {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Service Run Name
          Text(
            widget.serviceRun.name,
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Route Name
          Text(
            widget.serviceRun.routeName,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Machine Count
          Text(
            '${widget.serviceRun.machineCount} machines',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.primary,
            size: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'View',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}