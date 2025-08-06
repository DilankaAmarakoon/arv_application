import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Models/machine_pick_list_model.dart';
import '../constants/theme.dart';
import 'basket_number_popup.dart';

class PickerFillerMatchingCart extends StatefulWidget {
  final String role;
  final MachinePickListModel machine;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoublePress;
  final bool isSelected;
  final bool isSelectionMode;

  const PickerFillerMatchingCart({
    super.key,
    required this.role,
    required this.machine,
    required this.onTap,
    this.onLongPress,
    this.onDoublePress,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  @override
  State<PickerFillerMatchingCart> createState() => _PickerFillerMatchingCartState();
}

class _PickerFillerMatchingCartState extends State<PickerFillerMatchingCart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Added for basket number functionality
  List<String> basketNumberList = [];

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

  // Added basket number dialog handler

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.machine.name != 0;
    final isPicked = widget.role == "picker" && (widget.machine.state == 'picked' || widget.machine.state == 'filled') && isActive;
    final isFilled = widget.role != "picker" && widget.machine.state == 'filled' && isActive;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: widget.isSelected ? 6 : 3,
        shadowColor: widget.isSelected
            ? AppColors.primary.withOpacity(0.4)
            : AppColors.primary.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onDoubleTap: widget.onDoublePress,
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
                colors: widget.isSelected
                    ? [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ]
                    : [
                  AppColors.surface,
                  AppColors.surface.withOpacity(0.95),
                ],
              ),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primary.withOpacity(0.8)
                    : isPicked || isFilled
                    ? AppColors.success.withOpacity(0.3)
                    : isActive
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.divider,
                width: widget.isSelected ? 2.5 : 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Selection indicator
                if (widget.isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                // Main content
                Row(
                  children: [
                    _buildMachineIcon(isActive, isPicked, isFilled),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildMachineInfo()),
                    if (!widget.isSelectionMode)
                      _buildActionButton(isPicked, isFilled),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMachineIcon(bool isActive, bool isPicked, bool isFilled) {
    Color iconColor;
    Color backgroundColor;
    Color borderColor;
    IconData iconData;

    if (isPicked || isFilled) {
      iconColor = AppColors.primary;
      backgroundColor = AppColors.success.withOpacity(0.1);
      borderColor = AppColors.success.withOpacity(0.3);
      iconData = Icons.kitchen;
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
          color: widget.isSelected
              ? AppColors.primary.withOpacity(0.6)
              : borderColor,
          width: widget.isSelected ? 3 : 2,
        ),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  // Updated to include basket number functionality
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
              color: widget.isSelected
                  ? AppColors.primary
                  : AppColors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          if(widget.machine.basketNumbers.isNotEmpty)Row(
            children: [
              Icon(
                Icons.shopping_basket,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  widget.machine.basketNumbersDisplay.join(' | ') ?? '',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Instruction label
          if(widget.role == "picker"  && !widget.isSelectionMode)Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 0.8,
              ),
            ),
            child: Text(
              'Tap to doubleTap scan basket number',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: 9,
                letterSpacing: 0.2,
              ),
            ),
          ),
          // Basket number badges
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

  Widget _buildActionButton(bool isPicked, bool isFilled) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: isPicked || isFilled
                ? Colors.green.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPicked || isFilled ? Icons.check : Icons.arrow_forward_ios,
            color: isPicked || isFilled ? Colors.green : AppColors.primary,
            size: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isPicked ? 'Picked' : isFilled ? 'Filled' : widget.role == "picker" ? 'Pick' : 'Fill',
          style: AppTextStyles.caption.copyWith(
            color: isPicked || isFilled ? Colors.green : AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
