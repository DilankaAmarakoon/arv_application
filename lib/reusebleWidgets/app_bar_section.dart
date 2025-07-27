import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_state_provider.dart';
import '../constants/theme.dart';
import '../widgets/notification_cart.dart';

class appBarSection extends StatelessWidget implements PreferredSizeWidget {
  final IconData icon;
  final String headerTitle1;
  final String headerTitle2;
  final List<Widget>? actions;
  final bool showNotification;

  const appBarSection({
    super.key,
    required this.icon,
    required this.headerTitle1,
    required this.headerTitle2,
    this.actions,
    this.showNotification = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:AppColors.primary.withOpacity(0.2),
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.shadow,
      toolbarHeight: 80, // Increased height
      automaticallyImplyLeading: false, // Remove default back button
      title: Row(
        children: [
          // Container(
          //   width: 30,
          //   height: 30,
          //   decoration: BoxDecoration(
          //     color: AppColors.primary.withOpacity(0.2),
          //     shape: BoxShape.circle,
          //   ),
          //   child: Icon(
          //     icon,
          //     color: AppColors.primary,
          //     size: 30,
          //   ),
          // ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  headerTitle1,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  headerTitle2,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (showNotification) _buildNotificationButton(context),
        if (actions != null) ...actions!,
        Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
      ],
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    NotificationCart notificationCart = NotificationCart();
    return Consumer<NotificationStateProvider>(
      builder: (context, notificationProvider, child) {
        return Stack(
          children: [
            IconButton(
              onPressed: () {
                if (notificationProvider.notificationCount > 0) {
                  notificationCart.notificationPressed(context);
                }
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: notificationProvider.notificationCount > 0
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
            if (notificationProvider.notificationCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${notificationProvider.notificationCount}',
                    style: const TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80); // Increased height
}