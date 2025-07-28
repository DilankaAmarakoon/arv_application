import 'package:flutter/material.dart';
import '../Models/machine_pick_list_model.dart';
import '../constants/theme.dart';

class PickerFillerMatchingCart extends StatefulWidget {
  final String role;
  final MachinePickListModel machine;
  final VoidCallback onTap;

  const PickerFillerMatchingCart({
    super.key,
    required this.role,
    required this.machine,
    required this.onTap,
  });

  @override
  State<PickerFillerMatchingCart> createState() => _PickerFillerMatchingCartState();
}

class _PickerFillerMatchingCartState extends State<PickerFillerMatchingCart>
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

    print("dfdfdfdf.....${widget.machine.state}");
    final isActive = widget.machine.name != 0;
    final isPicked = widget.machine.state == 'picked' && isActive;

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
              minHeight: 50,
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
                color: isPicked
                    ? AppColors.success.withOpacity(0.3)
                    : isActive
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.divider,
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Status badge positioned at top right
                // Positioned(
                //   top: 0,
                //   right: 0,
                //   child: _buildStatusBadge(),
                // ),
                // Main content
                Row(
                  children: [
                    _buildMachineIcon(isActive, isPicked),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildMachineInfo()),
                    _buildActionButton(isPicked),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMachineIcon(bool isActive, bool isPicked) {
    Color iconColor;
    Color backgroundColor;
    Color borderColor;
    IconData iconData;

    if (isPicked) {
      iconColor = AppColors.success;
      backgroundColor = AppColors.success.withOpacity(0.1);
      borderColor = AppColors.success.withOpacity(0.3);
      iconData = Icons.check_circle;
    } else if (isActive) {
      iconColor = AppColors.primary;
      backgroundColor = AppColors.primary.withOpacity(0.1);
      borderColor = AppColors.primary.withOpacity(0.3);
      iconData = Icons.kitchen;
    } else {
      iconColor = AppColors.warning;
      backgroundColor = AppColors.warning.withOpacity(0.1);
      borderColor = AppColors.warning.withOpacity(0.3);
      iconData = Icons.kitchen;
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

  Widget _buildMachineInfo() {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.machine.name,
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          if (widget.machine.name.isNotEmpty) ...[
            // Additional machine info can be added here if needed
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isActive = widget.machine.name != 0;
    final isPicked = widget.role == 'picker' && isActive;

    String statusText;
    Color statusColor;

    if (isPicked) {
      statusText = 'Picked';
      statusColor = AppColors.success;
    } else if (isActive) {
      statusText = 'Active';
      statusColor = AppColors.primary;
    } else {
      statusText = 'Inactive';
      statusColor = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.caption.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildActionButton(bool isPicked) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: isPicked
                ? AppColors.success.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPicked ? Icons.check : Icons.arrow_forward_ios,
            color: isPicked ? AppColors.success : AppColors.primary,
            size: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isPicked ? 'Picked' : 'View',
          style: AppTextStyles.caption.copyWith(
            color: isPicked ? AppColors.success : AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}