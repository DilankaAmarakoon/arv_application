import 'package:flutter/material.dart';
import '../Models/picker_machine_product.dart';
import '../constants/theme.dart';

class ProfessionalProductCard extends StatefulWidget {
  final String role;
  final bool bulkView;
  final PickerMachineProductModel product;
  final bool isSelected;
  final int quantity;
  final VoidCallback onSelectionChanged;
  final ValueChanged<int> onQuantityChanged;

  const ProfessionalProductCard({
    super.key,
    required this.role,
    required this.bulkView,
    required this.product,
    required this.isSelected,
    required this.quantity,
    required this.onSelectionChanged,
    required this.onQuantityChanged,
  });

  @override
  State<ProfessionalProductCard> createState() => _ProfessionalProductCardState();
}

class _ProfessionalProductCardState extends State<ProfessionalProductCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: AppColors.surface,
      end: AppColors.primary.withOpacity(0.05),
    ).animate(_animationController);

    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ProfessionalProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primary.withOpacity(0.4)
                    : AppColors.divider,
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.shadow,
                  blurRadius: widget.isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onSelectionChanged,
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      _buildProductIcon(),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: _buildProductInfo()),
                      // _buildQuantityControls(),
                      const SizedBox(width: AppSpacing.md),
                      // _buildSelectionCheckbox(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: widget.isSelected
            ? AppColors.primary.withOpacity(0.2)
            : AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.isSelected
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.primary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name
        Text(
          widget.product.displayName,
          style: AppTextStyles.subtitle1.copyWith(
            fontWeight: FontWeight.bold,
            color: widget.isSelected
                ? AppColors.primary
                : AppColors.onSurface,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Machine name with icon
        if(widget.role == "picker" && widget.bulkView)Row(
          children: [
            Icon(
              Icons.kitchen,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                widget.product.machineName,
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
        const SizedBox(height: AppSpacing.xs),

        // Pick/Fill amount
        Text(
          widget.role == "picker"
              ? "Pick Amount: ${widget.product.pickAmount}"
              : "Fill Amount: ${widget.product.pickAmount}",
          style: AppTextStyles.body2.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// Alternative layout with machine name as a badge
class ProfessionalProductCardWithBadge extends StatefulWidget {
  final String role;
  final PickerMachineProductModel product;
  final String machineName;
  final bool isSelected;
  final int quantity;
  final VoidCallback onSelectionChanged;
  final ValueChanged<int> onQuantityChanged;

  const ProfessionalProductCardWithBadge({
    super.key,
    required this.role,
    required this.product,
    required this.machineName,
    required this.isSelected,
    required this.quantity,
    required this.onSelectionChanged,
    required this.onQuantityChanged,
  });

  @override
  State<ProfessionalProductCardWithBadge> createState() => _ProfessionalProductCardWithBadgeState();
}

class _ProfessionalProductCardWithBadgeState extends State<ProfessionalProductCardWithBadge>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: AppColors.surface,
      end: AppColors.primary.withOpacity(0.05),
    ).animate(_animationController);

    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ProfessionalProductCardWithBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primary.withOpacity(0.4)
                    : AppColors.divider,
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.shadow,
                  blurRadius: widget.isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onSelectionChanged,
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                child: Stack(
                  children: [
                    // Machine name badge positioned at top right
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _buildMachineBadge(),
                    ),
                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          _buildProductIcon(),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(child: _buildProductInfo()),
                          const SizedBox(width: AppSpacing.md),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMachineBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.kitchen,
            size: 12,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            widget.machineName,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: widget.isSelected
            ? AppColors.primary.withOpacity(0.2)
            : AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.isSelected
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.primary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xl), // Space for badge
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            widget.product.displayName,
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.isSelected
                  ? AppColors.primary
                  : AppColors.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Pick/Fill amount
          Text(
            widget.role == "picker"
                ? "Pick Amount: ${widget.product.pickAmount}"
                : "Fill Amount: ${widget.product.pickAmount}",
            style: AppTextStyles.body2.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}