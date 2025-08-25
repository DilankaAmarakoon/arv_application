
import 'package:flutter/material.dart';
import '../Models/picker_machine_product.dart';
import '../constants/theme.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


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
  late AnimationController _toggleController;
  late Animation<double> _toggleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _toggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _toggleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _toggleController,
      curve: Curves.elasticOut,
    ));

    if (widget.isSelected) {
      _toggleController.forward();
    }
  }

  @override
  void didUpdateWidget(ProfessionalProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _toggleController.forward();
      } else {
        _toggleController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _toggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    String? base64String = widget.product.displayImage;
    Uint8List? imageByte;

    if (base64String != null && base64String.isNotEmpty) {
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }
      try {
        imageByte = base64Decode(base64String);
      } catch (e) {
        debugPrint("Image decode error: $e");
      }
    }
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 70,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(
            color: widget.isSelected
                ? AppColors.primary
                : AppColors.divider,
            width: widget.isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected
                  ? AppColors.primary.withOpacity(0.15)
                  : AppColors.shadow.withOpacity(0.5),
              blurRadius: widget.isSelected ? 8 : 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              _buildProductImage(imageByte),
              const SizedBox(width: AppSpacing.md),
              Expanded(flex: 2,child: _buildProductInfo()),
              const SizedBox(width: AppSpacing.sm),
              _buildToggleButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(imageByte) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: widget.isSelected
            ? AppColors.primary.withOpacity(0.15)
            : AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(
          color: widget.isSelected
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageByte != null
            ? Image.memory(
          imageByte,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder();
          },
        )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade300,
          ],
        ),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        color: Colors.grey.shade500,
        size: 32,
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Product name
        Text(
          widget.product.displayName,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: widget.isSelected
                ? AppColors.primary
                : AppColors.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),

        // Pick/Fill amount
        Text(
          widget.role == "picker"
              ? "Pick: ${widget.product.pickAmount}"
              : "Fill: ${widget.product.pickAmount}",
          style: AppTextStyles.caption.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Machine name for bulk view
        if (widget.role == "picker" && widget.bulkView) ...[
          const SizedBox(height: 1),
          Row(
            children: [
              Icon(
                Icons.kitchen,
                size: 12,
                color: AppColors.onSurfaceVariant.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.product.machineName,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onSurfaceVariant.withOpacity(0.8),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: widget.onSelectionChanged, // Call the selection function when tapped
      child: AnimatedBuilder(
        animation: _toggleAnimation,
        builder: (context, child) {
          return Container(
            width: 44,
            height: 24,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.primary
                  : AppColors.disabled.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primary
                    : AppColors.disabled,
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Toggle circle
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: widget.isSelected ? 22 : 2,
                  top: 2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),

                // Optional checkmark when selected
                if (widget.isSelected)
                  Positioned(
                    left: 4,
                    top: 4,
                    child: Transform.scale(
                      scale: _toggleAnimation.value,
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
