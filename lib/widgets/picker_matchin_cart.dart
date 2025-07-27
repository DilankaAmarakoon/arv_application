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
    final isActive = widget.machine.name != 0;

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
            padding: const EdgeInsets.all(AppSpacing.md), // Reduced padding
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
                color: isActive
                    ? AppColors.success.withOpacity(0.3)
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
                    _buildMachineIcon(isActive),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildMachineInfo()),
                    _buildActionButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMachineIcon(bool isActive) {
    return Container(
      width: 50, // Reduced size
      height: 50, // Reduced size
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? AppColors.success.withOpacity(0.3)
              : AppColors.warning.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.kitchen,
        color: isActive ? AppColors.success : AppColors.warning,
        size: 24, // Reduced icon size
      ),
    );
  }

  Widget _buildMachineInfo() {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.lg), // Add padding to avoid overlap with status badge
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
            // Row(
            //   children: [
            //     Icon(
            //       Icons.route_outlined,
            //       size: 14, // Reduced icon size
            //       color: AppColors.onSurfaceVariant,
            //     ),
            //     const SizedBox(width: AppSpacing.xs),
            //     Expanded(
            //       child: Text(
            //         "widget.machine.routeName",
            //         style: AppTextStyles.caption.copyWith(
            //           color: AppColors.onSurfaceVariant,
            //         ),
            //         maxLines: 1,
            //         overflow: TextOverflow.ellipsis,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ],
      ),
    );
  }

  // Widget _buildStatusBadge() {
  //   final isActive = widget.machine.machineCount > 0;
  //
  //   return Container(
  //     padding: const EdgeInsets.symmetric(
  //       horizontal: AppSpacing.sm,
  //       vertical: 2,
  //     ),
  //     decoration: BoxDecoration(
  //       color: isActive
  //           ? AppColors.success.withOpacity(0.1)
  //           : AppColors.warning.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(AppBorderRadius.sm),
  //       border: Border.all(
  //         color: isActive
  //             ? AppColors.success.withOpacity(0.3)
  //             : AppColors.warning.withOpacity(0.3),
  //       ),
  //     ),
  //     child: Text(
  //       isActive ? 'Active' : 'Inactive',
  //       style: AppTextStyles.caption.copyWith(
  //         color: isActive ? AppColors.success : AppColors.warning,
  //         fontWeight: FontWeight.w600,
  //         fontSize: 10, // Slightly smaller text for the badge
  //       ),
  //     ),
  //   );
  // }

  Widget _buildActionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 35, // Reduced size
          height: 35, // Reduced size
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.primary,
            size: 16, // Reduced icon size
          ),
        ),
        const SizedBox(height: 2), // Reduced spacing
        Text(
          'View',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 10, // Slightly smaller text
          ),
        ),
      ],
    );
  }
}