import 'package:flutter/material.dart';
import '../Models/machine_pick_list_model.dart';
import '../constants/theme.dart';

class PickerFillerMatchingCart extends StatefulWidget {
  final String role;
  final MachinePickListModel machine;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isSelectionMode;

  const PickerFillerMatchingCart({
    super.key,
    required this.role,
    required this.machine,
    required this.onTap,
    this.onLongPress,
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
          isPicked ? 'Picked' : isFilled ? 'Filled' : 'View',
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

// Parent widget example for managing selection state
class CartListPage extends StatefulWidget {
  const CartListPage({super.key});

  @override
  State<CartListPage> createState() => _CartListPageState();
}

class _CartListPageState extends State<CartListPage> {
  List<String> selectedCartIds = [];
  bool isSelectionMode = false;

  void _handleLongPress(String cartId) {
    setState(() {
      if (!isSelectionMode) {
        isSelectionMode = true;
        selectedCartIds.add(cartId);
      } else {
        _toggleSelection(cartId);
      }
    });
  }

  void _handleTap(String cartId) {
    if (isSelectionMode) {
      _toggleSelection(cartId);
    } else {
      // Normal tap behavior
      print('Cart tapped: $cartId');
    }
  }

  void _toggleSelection(String cartId) {
    setState(() {
      if (selectedCartIds.contains(cartId)) {
        selectedCartIds.remove(cartId);
        if (selectedCartIds.isEmpty) {
          isSelectionMode = false;
        }
      } else {
        selectedCartIds.add(cartId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      selectedCartIds.clear();
      isSelectionMode = false;
    });
  }

  void _handleViewSelected() {
    // Handle view action for selected carts
    print('Viewing selected carts: $selectedCartIds');
    // Add your view logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectionMode
            ? '${selectedCartIds.length} selected'
            : 'Cart List'),
        actions: [
          if (isSelectionMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSelection,
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // Replace with your actual cart list
        itemBuilder: (context, index) {
          final cartId = 'cart_$index';
          final machine = MachinePickListModel(
            name: 'Machine $index',
            state: index % 3 == 0 ? 'pickive': 'active', id: 0, pick_list_id: 0, pickListIds: [],
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PickerFillerMatchingCart(
              role: 'picker',
              machine: machine,
              onTap: () => _handleTap(cartId),
              onLongPress: () => _handleLongPress(cartId),
              isSelected: selectedCartIds.contains(cartId),
              isSelectionMode: isSelectionMode,
            ),
          );
        },
      ),
      floatingActionButton: selectedCartIds.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _handleViewSelected,
        icon: const Icon(Icons.visibility),
        label: const Text('View'),
        backgroundColor: AppColors.primary,
      )
          : null,
    );
  }
}