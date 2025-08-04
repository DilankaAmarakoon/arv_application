
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_mangement/screens/picker_filler_section.dart';
import 'package:staff_mangement/screens/picker_filler_service_run.dart';
import 'package:staff_mangement/screens/staff_screen.dart';
import '../providers/notification_state_provider.dart';
import '../reusebleWidgets/app_bar_section.dart';
import '../constants/theme.dart';
import '../widgets/profile_section_drawer.dart';
import 'filler_screen.dart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;


  final List<DashboardItem> _dashboardItems = [
    DashboardItem(
      title: 'Staff Management',
      subtitle: 'Manage staff tasks and assignments',
      icon: Icons.people_outline,
      color: AppColors.primary,
      route: '/staff',
    ),
    DashboardItem(
      title: 'Picker Operations',
      subtitle: 'Monitor and manage vending machines',
      icon: Icons.kitchen,
      color: AppColors.primary,
      route: '/picker',
    ),
    DashboardItem(
      title: 'Filler Operations',
      subtitle: 'Monitor and manage vending machines',
      icon: Icons.kitchen,
      color: AppColors.primary,
      route: '/filer',
    ),
    // DashboardItem(
    //   title: 'Analytics',
    //   subtitle: 'View performance metrics and reports',
    //   icon: Icons.analytics_outlined,
    //   color: AppColors.info,
    //   route: '/analytics',
    // ),
    // DashboardItem(
    //   title: 'Notifications',
    //   subtitle: 'Manage alerts and notifications',
    //   icon: Icons.notifications_outlined,
    //   color: AppColors.warning,
    //   route: '/notifications',
    // ),
  ];


  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadInitialData();
  }

   _setupAnimations() async{
    // machineData = await machineDetailsData.fetchPickerMachineData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  _loadInitialData() async {
    // Load data using the provider

  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: appBarSection(
        icon: Icons.analytics_outlined,
        headerTitle1: 'Welcome Back!',
        headerTitle2: 'Manage your operations efficiently',
        showNotification: true,
      ),
      endDrawer: const ProfileSectionDrawer(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: RefreshIndicator(
            onRefresh: _refreshDashboard,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  _buildQuickStats(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildDashboardGrid(),
                  const SizedBox(height: AppSpacing.xl),
                  // _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Active Tasks',
            '12',
            Icons.task_alt,
            AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            'Machines',
            '8',
            Icons.precision_manufacturing,
            AppColors.info,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            'Alerts',
            '3',
            Icons.warning_outlined,
            AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.1,
            ),
            itemCount: _dashboardItems.length,
            itemBuilder: (context, index) {
              return _buildDashboardCard(_dashboardItems[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(DashboardItem item, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: SizedBox(
            height: 700,
            child: Card(
              elevation: 4,
              shadowColor: item.color.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
              child: InkWell(
                onTap: () => _navigateToScreen(item.route),
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        item.color.withOpacity(0.1),
                        item.color.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          color: item.color,
                          size: 26,
                        ),
                      ),
                      // const SizedBox(height: AppSpacing.md),
                      Text(
                        item.title,
                        style: AppTextStyles.subtitle2.copyWith(
                          color: item.color,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // const SizedBox(height: AppSpacing.xs),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: AppTextStyles.heading3,
            ),
            TextButton(
              onPressed: () {
                // Navigate to full activity log
              },
              child: Text(
                'View All',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(3, (index) => _buildActivityItem(index)),
      ],
    );
  }

  Widget _buildActivityItem(int index) {
    final activities = [
      {
        'title': 'Task completed by John Doe',
        'subtitle': 'Machine maintenance task #M001',
        'time': '2 hours ago',
        'icon': Icons.task_alt,
        'color': AppColors.success,
      },
      {
        'title': 'New machine alert',
        'subtitle': 'Machine ARV411 requires attention',
        'time': '4 hours ago',
        'icon': Icons.warning_outlined,
        'color': AppColors.warning,
      },
      {
        'title': 'Staff check-in',
        'subtitle': 'Sarah Wilson started shift',
        'time': '6 hours ago',
        'icon': Icons.login,
        'color': AppColors.info,
      },
    ];

    final activity = activities[index];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: AppTextStyles.subtitle2,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  activity['subtitle'] as String,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            activity['time'] as String,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(String route) {
    Widget screen;
    switch (route) {
      case '/staff':
        screen = const StaffScreen();
        break;
      case '/picker':
        screen =  PickerServiceRunScreen(role:"picker");
        // screen =  PickerFillerScreen(role:"picker");
        break;
        case '/filer':
        screen =  PickerServiceRunScreen(role:"filler");
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _refreshDashboard() async {
    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));

    // Update notification count
    if (mounted) {
      Provider.of<NotificationStateProvider>(context, listen: false)
          .fetchNotificationCount(0);
    }
  }
}

class DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

